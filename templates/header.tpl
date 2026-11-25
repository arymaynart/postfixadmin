<!doctype html>
<html lang="{if isset($smarty.session.lang)}{$smarty.session.lang}{/if}">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>

    {* see https://github.com/postfixadmin/postfixadmin/issues/497 *}
    <meta http-equiv='Content-Security-Policy' content="default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; "/>

    <title>mARTdesign Mail Admin - {$smarty.server.HTTP_HOST}</title>
    <link rel="icon" type="image/svg+xml" href="{$CONF.theme_favicon}"/>
    <link rel="shortcut icon" href="{$CONF.theme_favicon}"/>
    {literal}<script>
    (function () {
        try {
            var saved = localStorage.getItem('pfa_mart_theme');
            document.documentElement.setAttribute('data-theme', saved === 'carbono' ? 'carbono' : 'creme');
        } catch (e) {
            document.documentElement.setAttribute('data-theme', 'creme');
        }
    })();
    function pfaToggleTheme() {
        var cur = document.documentElement.getAttribute('data-theme') === 'carbono' ? 'carbono' : 'creme';
        var next = cur === 'carbono' ? 'creme' : 'carbono';
        document.documentElement.setAttribute('data-theme', next);
        try { localStorage.setItem('pfa_mart_theme', next); } catch (e) {}
    }
    </script>{/literal}
    <link rel="stylesheet" type="text/css" href="{$CONF.theme_css}"/>
    {if $CONF.theme_custom_css}
        <link rel="stylesheet" type="text/css" href="{$CONF.theme_custom_css}"/>
    {/if}

    <!-- needed for datetimepicker -->
    <script src="{$rel_path}jquery-3.7.0.min.js"></script>
    <script src="{$rel_path}css/bootstrap-3.4.1-dist/js/moment-with-locales.min.js"></script>
    <script src="{$rel_path}css/bootstrap-3.4.1-dist/js/bootstrap.min.js"></script>
    <script src="{$rel_path}css/bootstrap-3.4.1-dist/js/bootstrap-datetimepicker.min.js"></script>
</head>
<body class="lang-{if isset($smarty.session.lang)}{$smarty.session.lang}{/if} page-{$smarty_template} {if isset($table)}page-{$smarty_template}-{$table}{/if}">
