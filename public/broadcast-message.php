<?php

/**
 * Postfix Admin
 *
 * LICENSE
 * This source file is subject to the GPL license that is bundled with
 * this package in the file LICENSE.TXT.
 *
 * Further details on the project are available at https://github.com/postfixadmin/postfixadmin
 *
 * @version $Id$
 * @license GNU GPL v2 or later.
 *
 * File: broadcast-message.php
 * Used to send a message to _ALL_ users with mailboxes on this server.
 * Supports HTML wrapper (templates/email_base.html) and user/domain placeholders.
 */

require_once('common.php');

if (Config::bool('sendmail_all_admins')) {
    authentication_require_role('admin');
} else {
    authentication_require_role('global-admin');
}

$CONF = Config::getInstance()->getAll();
$smarty = PFASmarty::getInstance();
$PALANG = $CONF['__LANG'];

if ($CONF['sendmail'] != 'YES') {
    header("Location: main.php");
    exit;
}

$error = 0;

$smtp_from_email = smtp_get_admin_email();
$allowed_domains = list_domains_for_admin(authentication_get_username());

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    if (!isset($_SESSION['PFA_token']) || !hash_equals((string)$_SESSION['PFA_token'], safepost('token'))) {
        pfa_handle_invalid_token();
    }

    $posted_domains = (isset($_POST['domains']) && is_array($_POST['domains'])) ? $_POST['domains'] : array();
    $wanted_domains = array_intersect($allowed_domains, $posted_domains);

    if (empty($_POST['subject']) || empty($_POST['message']) || empty($_POST['name']) || empty($wanted_domains)) {
        $error = 1;
        flash_error($PALANG['pBroadcast_error_empty']);
    } else {
        $table_mailbox = table_by_key('mailbox');
        $table_alias = table_by_key('alias');

        $q = "SELECT username FROM $table_mailbox WHERE active='" . db_get_boolean(true) . "' AND " . db_in_clause("domain", $wanted_domains);
        if (intval(safepost('mailboxes_only')) == 0) {
            $q .= " UNION SELECT goto FROM $table_alias WHERE active='" . db_get_boolean(true) . "' AND " . db_in_clause("domain", $wanted_domains) . " AND goto NOT IN ($q)";
        }
        $result = db_query_all($q);
        $recipients = array_unique(array_column($result, 'username'));

        if (count($recipients) > 0) {
            mb_internal_encoding("UTF-8");
            $clean_name = trim(preg_replace('/[\r\n]+/', ' ', (string)$_POST['name']));
            $clean_subject = trim(preg_replace('/[\r\n]+/', ' ', (string)$_POST['subject']));
            $b_name = mb_encode_mimeheader($clean_name, 'UTF-8', 'Q');
            $b_subject = mb_encode_mimeheader($clean_subject, 'UTF-8', 'Q');

            $raw_message = (string)$_POST['message'];

            $rawServerName = isset($_SERVER['SERVER_NAME']) ? (string)$_SERVER['SERVER_NAME'] : php_uname('n');
            $serverName = preg_replace('/[^a-zA-Z0-9.\-]/', '', $rawServerName);
            if (empty($serverName)) {
                $serverName = 'localhost.localdomain';
            }

            foreach ($recipients as $rcpt) {
                $fTo = trim(preg_replace('/[\r\n<>]+/', '', (string)$rcpt));
                if ($fTo === '') {
                    continue;
                }

                $vars = fetch_user_and_domain_vars($fTo);
                $is_html = (strip_tags($raw_message) !== $raw_message);
                $filled_fragment = apply_placeholders($raw_message, $vars, $is_html);
                $msg_id = '<' . sprintf('%.6f', microtime(true)) . '-' . md5($smtp_from_email . $fTo) . "@{$serverName}>";

                if ($is_html) {
                    $final_html = build_html_from_template($filled_fragment, $clean_subject);
                    if ($final_html === false) {
                        $final_html = $filled_fragment;
                    }
                    list($mime_headers, $mime_body) = build_multipart_message(strip_tags($final_html), $final_html);

                    $fHeaders  = 'To: ' . $fTo . "\r\n";
                    $fHeaders .= 'From: ' . $b_name . ' <' . $smtp_from_email . ">\r\n";
                    $fHeaders .= 'Subject: ' . $b_subject . "\r\n";
                    $fHeaders .= 'Date: ' . date('r') . "\r\n";
                    $fHeaders .= 'Message-ID: ' . $msg_id . "\r\n";
                    $fHeaders .= rtrim($mime_headers, "\r\n") . "\r\n\r\n";
                    $fHeaders .= $mime_body;
                } else {
                    $b_message = chunk_split(base64_encode($filled_fragment));
                    $fHeaders  = 'To: ' . $fTo . "\r\n";
                    $fHeaders .= 'From: ' . $b_name . ' <' . $smtp_from_email . ">\r\n";
                    $fHeaders .= 'Subject: ' . $b_subject . "\r\n";
                    $fHeaders .= 'Date: ' . date('r') . "\r\n";
                    $fHeaders .= 'Message-ID: ' . $msg_id . "\r\n";
                    $fHeaders .= "MIME-Version: 1.0\r\n";
                    $fHeaders .= "Content-Type: text/plain; charset=UTF-8\r\n";
                    $fHeaders .= "Content-Transfer-Encoding: base64\r\n\r\n";
                    $fHeaders .= $b_message . "\r\n";
                }

                if (!smtp_mail($fTo, $smtp_from_email, $fHeaders, smtp_get_admin_password())) {
                    flash_error(Config::lang_f('pSendmail_result_error', $fTo));
                } else {
                    flash_info(Config::lang_f('pSendmail_result_success', $fTo));
                }
            }
        }
        flash_info($PALANG['pBroadcast_success']);
        $smarty->assign('allowed_domains', $allowed_domains);
        $smarty->assign('smtp_from_email', $smtp_from_email);
        $smarty->assign('error', $error);
        $smarty->assign('smarty_template', 'broadcast-message');
        $smarty->display('index.tpl');
    }
}

if ($_SERVER['REQUEST_METHOD'] == "GET" || $error == 1) {
    $smarty->assign('allowed_domains', $allowed_domains);
    $smarty->assign('smtp_from_email', $smtp_from_email);
    $smarty->assign('error', $error);
    $smarty->assign('smarty_template', 'broadcast-message');
    $smarty->display('index.tpl');
}

/* vim: set expandtab softtabstop=3 tabstop=3 shiftwidth=3: */
