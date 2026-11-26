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
 * File: sendmail.php
 * Used to send an email to a user.
 * Hardened: enforces sendmail_all_admins, restricts non-superadmins to managed domains,
 * sanitizes headers, and supports HTML template + user/domain placeholders.
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

$smtp_from_email = smtp_get_admin_email();
$allowed_domains = list_domains_for_admin(authentication_get_username());

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    if (!isset($_SESSION['PFA_token']) || !hash_equals((string)$_SESSION['PFA_token'], safepost('token'))) {
        pfa_handle_invalid_token();
    }

    $fTo = trim(preg_replace('/[\r\n<>]+/', '', safepost('fTo')));
    $fFrom = $smtp_from_email;
    $fSubject = trim(preg_replace('/[\r\n]+/', ' ', safepost('fSubject')));
    $raw_body = isset($_POST['fBody']) && is_string($_POST['fBody']) ? $_POST['fBody'] : '';

    $error = 0;
    $email_check = check_email($fTo);
    $to_domain = '';
    if (strpos($fTo, '@') !== false) {
        $parts = explode('@', $fTo);
        $to_domain = strtolower(trim(end($parts)));
    }

    if (empty($fTo) || ($email_check != '') || empty($to_domain)) {
        $error = 1;
        $tTo = escape_string($fTo);
        $tSubject = escape_string($fSubject);
        flash_error($PALANG['pSendmail_to_text_error']);
        if ($email_check != '') {
            flash_error($email_check);
        }
    } elseif (!authentication_has_role('global-admin') && !in_array($to_domain, $allowed_domains, true)) {
        $error = 1;
        $tTo = escape_string($fTo);
        $tSubject = escape_string($fSubject);
        flash_error($PALANG['pSendmail_to_text_error']);
    }

    if ($error != 1) {
        $vars = fetch_user_and_domain_vars($fTo);
        $is_html = (strip_tags($raw_body) !== $raw_body);
        $filled_fragment = apply_placeholders($raw_body, $vars, $is_html);
        $html_fragment = format_email_body_html($filled_fragment, $is_html);

        $tBody = build_html_from_template($html_fragment, $fSubject, true);
        if ($tBody === false) {
            $tBody = $filled_fragment;
        }

        if (!smtp_mail($fTo, $fFrom, $fSubject, smtp_get_admin_password(), $tBody)) {
            flash_error(Config::lang_f('pSendmail_result_error', $fTo));
        } else {
            flash_info(Config::lang_f('pSendmail_result_success', $fTo));
        }
    }
}

$smarty->assign('smtp_from_email', $smtp_from_email);
$smarty->assign('smarty_template', 'sendmail');
$smarty->display('index.tpl');


/* vim: set expandtab softtabstop=3 tabstop=3 shiftwidth=3: */
