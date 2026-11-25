<!-- {$smarty.template} -->
<div class="mf-page-header">
    <div class="mf-page-header-left">
        <p class="mf-eyebrow">Painel de E-mail</p>
        <h1 class="mf-page-title">{$PALANG.pMain_dashboard}</h1>
    </div>
    <div class="mf-page-header-actions">
        <div class="mf-header-control">
            <form method="GET" action="">
                <input type="text" id="q" name="q" class="form-control" style="width:280px;" value="{$q}" autofocus="autofocus"
                       placeholder="{$PALANG.pMain_global_search_placeholder}"
                       aria-label="{$PALANG.pMain_global_search}">
                <button class="mf-btn-primary" type="submit">
                    <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    {$PALANG.pMain_search_button}
                </button>
            </form>
        </div>
    </div>
</div>

<div class="mf-content" id="main_menu">
    {if !empty($domains) || !empty($mailboxes) || !empty($aliases)}
        <div class="mf-table-wrapper">
            <div class="mf-nav-list">
                {if !empty($domains)}
                    {foreach from=$domains item=row}
                        <a class="mf-nav-row" href="list-virtual.php?domain={$row['domain']|escape:url}">
                            <div class="mf-nav-row-left">
                                <span class="mf-badge">{$PALANG.domain}</span>
                                <span class="mf-nav-title">{$row['domain']}</span>
                            </div>
                            <svg class="mf-nav-arrow" viewBox="0 0 24 24" aria-hidden="true"><polyline points="9 18 15 12 9 6"/></svg>
                        </a>
                    {/foreach}
                {/if}
                {if !empty($mailboxes)}
                    {foreach from=$mailboxes item=row}
                        <a class="mf-nav-row" href="edit.php?table=mailbox&amp;edit={$row['username']|escape:url}">
                            <div class="mf-nav-row-left">
                                <span class="mf-badge-solid">{$PALANG.pOverview_mailbox_username}</span>
                                <span class="mf-nav-title">{$row['username']}</span>
                            </div>
                            <svg class="mf-nav-arrow" viewBox="0 0 24 24" aria-hidden="true"><polyline points="9 18 15 12 9 6"/></svg>
                        </a>
                    {/foreach}
                {/if}
                {if !empty($aliases)}
                    {foreach from=$aliases item=row}
                        <a class="mf-nav-row" href="edit.php?table=alias&amp;edit={$row['address']|escape:url}">
                            <div class="mf-nav-row-left">
                                <span class="mf-badge-solid">Alias</span>
                                <span class="mf-nav-title">{$row['address']}</span>
                            </div>
                            <svg class="mf-nav-arrow" viewBox="0 0 24 24" aria-hidden="true"><polyline points="9 18 15 12 9 6"/></svg>
                        </a>
                    {/foreach}
                {/if}
            </div>
        </div>
    {/if}

    <div class="mf-table-wrapper">
        <div class="mf-nav-list">
            <a class="mf-nav-row" href="{#url_list_domain#}">
                <div class="mf-nav-row-left">
                    <div class="mf-nav-tile"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg></div>
                    <div>
                        <div class="mf-nav-title">{$PALANG.pMenu_overview}</div>
                        <div class="mf-nav-desc">{$PALANG.pMain_overview}</div>
                    </div>
                </div>
                <svg class="mf-nav-arrow" viewBox="0 0 24 24" aria-hidden="true"><polyline points="9 18 15 12 9 6"/></svg>
            </a>
            <a class="mf-nav-row" href="{#url_create_mailbox#}">
                <div class="mf-nav-row-left">
                    <div class="mf-nav-tile"><svg viewBox="0 0 24 24" aria-hidden="true"><rect width="20" height="16" x="2" y="4" rx="2"/><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/></svg></div>
                    <div>
                        <div class="mf-nav-title">{$PALANG.add_mailbox}</div>
                        <div class="mf-nav-desc">{$PALANG.pMain_create_mailbox}</div>
                    </div>
                </div>
                <svg class="mf-nav-arrow" viewBox="0 0 24 24" aria-hidden="true"><polyline points="9 18 15 12 9 6"/></svg>
            </a>
            <a class="mf-nav-row" href="{#url_create_alias#}">
                <div class="mf-nav-row-left">
                    <div class="mf-nav-tile"><svg viewBox="0 0 24 24" aria-hidden="true"><polyline points="15 14 20 9 15 4"/><path d="M4 20v-7a4 4 0 0 1 4-4h12"/></svg></div>
                    <div>
                        <div class="mf-nav-title">{$PALANG.add_alias}</div>
                        <div class="mf-nav-desc">{$PALANG.pMain_create_alias}</div>
                    </div>
                </div>
                <svg class="mf-nav-arrow" viewBox="0 0 24 24" aria-hidden="true"><polyline points="9 18 15 12 9 6"/></svg>
            </a>
            {if $CONF.sendmail==='YES'}
                <a class="mf-nav-row" href="{#url_sendmail#}">
                    <div class="mf-nav-row-left">
                        <div class="mf-nav-tile"><svg viewBox="0 0 24 24" aria-hidden="true"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg></div>
                        <div>
                            <div class="mf-nav-title">{$PALANG.pMenu_sendmail}</div>
                            <div class="mf-nav-desc">{$PALANG.pMain_sendmail}</div>
                        </div>
                    </div>
                    <svg class="mf-nav-arrow" viewBox="0 0 24 24" aria-hidden="true"><polyline points="9 18 15 12 9 6"/></svg>
                </a>
            {/if}
            {if $CONF.dkim==='YES' && ($authentication_has_role.global_admin || (isset($CONF.dkim_all_admins) && $CONF.dkim_all_admins === 'YES'))}
                <a class="mf-nav-row" href="{#url_dkim#}">
                    <div class="mf-nav-row-left">
                        <div class="mf-nav-tile"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></div>
                        <div>
                            <div class="mf-nav-title">{$PALANG.pMenu_dkim}</div>
                            <div class="mf-nav-desc">{$PALANG.pMain_dkim}</div>
                        </div>
                    </div>
                    <svg class="mf-nav-arrow" viewBox="0 0 24 24" aria-hidden="true"><polyline points="9 18 15 12 9 6"/></svg>
                </a>
            {/if}
            <a class="mf-nav-row" href="{#url_password#}">
                <div class="mf-nav-row-left">
                    <div class="mf-nav-tile"><svg viewBox="0 0 24 24" aria-hidden="true"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></div>
                    <div>
                        <div class="mf-nav-title">{$PALANG.pMenu_password}</div>
                        <div class="mf-nav-desc">{$PALANG.pMain_password}</div>
                    </div>
                </div>
                <svg class="mf-nav-arrow" viewBox="0 0 24 24" aria-hidden="true"><polyline points="9 18 15 12 9 6"/></svg>
            </a>
            {if $CONF.logging==='YES'}
                <a class="mf-nav-row" href="{#url_viewlog#}">
                    <div class="mf-nav-row-left">
                        <div class="mf-nav-tile"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg></div>
                        <div>
                            <div class="mf-nav-title">{$PALANG.pMenu_viewlog}</div>
                            <div class="mf-nav-desc">{$PALANG.pMain_viewlog}</div>
                        </div>
                    </div>
                    <svg class="mf-nav-arrow" viewBox="0 0 24 24" aria-hidden="true"><polyline points="9 18 15 12 9 6"/></svg>
                </a>
            {/if}
        </div>
    </div>
</div>
