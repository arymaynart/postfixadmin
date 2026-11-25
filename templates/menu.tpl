<!-- {$smarty.template} -->
{strip}
    {if !empty($smarty.get) && !empty($smarty.get.domain)}
        {assign var="url_domain" value=$smarty.get.domain}
        {assign var="url_domain" value="&amp;domain={$url_domain|escape:url}"}
    {/if}
{/strip}

{strip}
    <nav class="navbar navbar-default navbar-fixed-top mf-topbar">
        <div class="container-fluid">
            <div class="navbar-header">
                <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar"
                        aria-expanded="false" aria-controls="navbar">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand" href='main.php'>
                    <img class="mf-logo-pos" src="{$rel_path}images/brand/martdesign-positivo-horizontal.svg" alt="mARTdesign"/>
                    <img class="mf-logo-neg" src="{$rel_path}images/brand/martdesign-negativo-horizontal.svg" alt="mARTdesign"/>
                </a>
            </div>
            <div id="navbar" class="collapse navbar-collapse">
                <ul class="nav navbar-nav">
                    {if $authentication_has_role.global_admin}
                        <li class="dropdown">
                            <a class="btn navbar-btn dropdown-toggle" data-toggle="dropdown" role="button"
                               aria-haspopup="true" aria-expanded="false" href="{#url_list_admin#}">{$PALANG.pAdminMenu_admin} <span class="caret"></span></a>
                            <ul class="dropdown-menu">
                                <li><a href="{#url_list_admin#}">{$PALANG.pAdminMenu_list_admin}</a></li>
                                <li><a href="{#url_create_admin#}">{$PALANG.pAdminMenu_create_admin}</a></li>
                            </ul>
                        </li>
                    {else}
                        <li><a class="btn navbar-btn" href="{#url_main#}">{$PALANG.pMenu_main}</a></li>
                    {/if}
                    <li class="dropdown">
                        <a class="btn navbar-btn dropdown-toggle" data-toggle="dropdown" role="button"
                           aria-haspopup="true" aria-expanded="false" href="{#url_list_domain#}">{$PALANG.pAdminMenu_domain} <span class="caret"></span></a>
                        <ul class="dropdown-menu">
                            <li><a href="{#url_list_domain#}">{$PALANG.pAdminMenu_list_domain}</a></li>
                            {if $authentication_has_role.global_admin}
                                <li><a href="{#url_edit_domain#}">{$PALANG.pAdminMenu_create_domain}</a></li>
                            {/if}
                        </ul>
                    </li>
                    <li class="dropdown">
                        <a class="btn navbar-btn dropdown-toggle" data-toggle="dropdown" role="button"
                           aria-haspopup="true" aria-expanded="false" href="{#url_list_virtual#}">{$PALANG.pAdminMenu_virtual} <span class="caret"></span></a>
                        <ul class="dropdown-menu">
                            <li><a href="{#url_list_virtual#}">{$PALANG.pAdminMenu_list_virtual}</a></li>
                            <li><a href="{#url_create_mailbox#}{$url_domain}">{$PALANG.add_mailbox}</a></li>
                            <li><a href="{#url_create_alias#}{$url_domain}">{$PALANG.add_alias}</a></li>
                            {if $boolconf_alias_domain}
                                <li><a href="{#url_create_alias_domain#}{$url_domain}">{$PALANG.add_alias_domain}</a></li>
                            {/if}
                        </ul>
                    </li>
                    {if $CONF.fetchmail==='YES'}
                        <li class="dropdown">
                            <a class="btn navbar-btn dropdown-toggle" data-toggle="dropdown" role="button"
                               aria-haspopup="true" aria-expanded="false" href="{#url_fetchmail#}">{$PALANG.pMenu_fetchmail_menu} <span class="caret"></span></a>
                            <ul class="dropdown-menu">
                                <li><a href="{#url_fetchmail#}">{$PALANG.pMenu_fetchmail}</a></li>
                                <li><a href="{#url_fetchmail_new_entry#}">{$PALANG.pFetchmail_new_entry}</a></li>
                            </ul>
                        </li>
                    {/if}
                    {if $CONF.sendmail==='YES'}
                        <li class="dropdown">
                            <a class="btn navbar-btn dropdown-toggle" data-toggle="dropdown" role="button"
                               aria-haspopup="true" aria-expanded="false" href="{#url_sendmail#}">{$PALANG.pMenu_sendmail_menu} <span class="caret"></span></a>
                            <ul class="dropdown-menu">
                                <li><a href="{#url_sendmail#}">{$PALANG.pMenu_sendmail}</a></li>
                                {if $authentication_has_role.global_admin || (isset($CONF.sendmail_all_admins) && $CONF.sendmail_all_admins === 'YES') }
                                    <li><a href="{#url_broadcast_message#}">{$PALANG.pAdminMenu_broadcast_message}</a></li>
                                {/if}
                            </ul>
                        </li>
                    {/if}
                    {if $CONF.dkim==='YES' && ($authentication_has_role.global_admin || (isset($CONF.dkim_all_admins) && $CONF.dkim_all_admins === 'YES'))}
                        <li class="dropdown">
                            <a class="btn navbar-btn dropdown-toggle" data-toggle="dropdown" role="button"
                               aria-haspopup="true" aria-expanded="false" href="{#url_dkim#}">{$PALANG.pMenu_dkim_menu} <span class="caret"></span></a>
                            <ul class="dropdown-menu">
                                <li><a href="{#url_dkim#}">{$PALANG.pMenu_dkim}</a></li>
                                <li><a href="{#url_dkim_signing#}">{$PALANG.pMenu_dkim_signing}</a></li>
                                <li><a href="{#url_dkim_newkey#}">{$PALANG.pDkim_new_key}</a></li>
                                <li><a href="{#url_dkim_newsign#}">{$PALANG.pDkim_new_sign}</a></li>
                            </ul>
                        </li>
                    {/if}
                    {if $CONF.totp==='YES'}
                        <li class="dropdown">
                            <a class="btn navbar-btn dropdown-toggle" data-toggle="dropdown" role="button"
                               aria-haspopup="true" aria-expanded="false" href="{#url_password#}">{$PALANG.pMenu_security} <span class="caret"></span></a>
                            <ul class="dropdown-menu">
                                <li><a href="{#url_password#}">{$PALANG.pMenu_password}</a></li>
                                <li><a href="{#url_totp#}">{$PALANG.pMenu_totp}</a></li>
                                <li><a href="{#url_totp_exceptions#}">{$PALANG.pMenu_totp_exceptions}</a></li>
                                <li><a href="{#url_app_passwords#}">{$PALANG.pMenu_app_passwords}</a></li>
                            </ul>
                        </li>
                    {else}
                        <li><a class="btn navbar-btn" href="{#url_password#}">{$PALANG.pMenu_password}</a></li>
                    {/if}
                    {if $authentication_has_role.global_admin && $CONF.database_type!=='pgsql' && $CONF.backup === 'YES'}
                        <li><a class="btn navbar-btn" href="{#url_backup#}">{$PALANG.pAdminMenu_backup}</a></li>
                    {/if}
                    {if $CONF.logging==='YES'}
                        <li><a class="btn navbar-btn" href="{#url_viewlog#}">{$PALANG.pMenu_viewlog}</a></li>
                    {/if}
                </ul>
                <div class="navbar-right mf-topbar-utils">
                    <button type="button" class="mf-icon-btn" onclick="pfaToggleTheme()" title="Alternar tema Carbono / Creme" aria-label="Alternar tema Carbono / Creme">
                        <svg class="mf-theme-icon-moon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"/></svg>
                        <svg class="mf-theme-icon-sun" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="4"/><path d="M12 2v2"/><path d="M12 20v2"/><path d="m4.93 4.93 1.41 1.41"/><path d="m17.66 17.66 1.41 1.41"/><path d="M2 12h2"/><path d="M20 12h2"/><path d="m6.34 17.66-1.41 1.41"/><path d="m19.07 4.93-1.41 1.41"/></svg>
                    </button>
                    <a class="mf-icon-btn mf-icon-btn--logout" href="{#url_logout#}" title="{$PALANG.pMenu_logout}" aria-label="{$PALANG.pMenu_logout}">
                        <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                    </a>
                </div>
            </div>
        </div>
    </nav>
{/strip}
