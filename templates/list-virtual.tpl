{assign var="file" value=$smarty.config.url_list_virtual}
{if isset($search._)}
    {assign var="searchsuffix" value="&amp;search[_]={$search._}"}
{else}
    {assign var="searchsuffix" value=""}
{/if}

<div id="overview" class="mf-page-header">
    <div class="mf-page-header-left">
        <p class="mf-eyebrow">Virtual · Domínio</p>
        <h1 class="mf-page-title">
            {if isset($search._)}
                {$PALANG.pSearch_welcome} {$search._}
            {else}
                {$fDomain}
            {/if}
        </h1>
        {if !isset($search._)}
            <div class="mf-header-meta">
                <span class="mf-badge">{$PALANG.mailboxes}: {$limit.mailbox_count} / {$limit.mailboxes}</span>
                <span class="mf-badge-solid">{$PALANG.aliases}: {$limit.alias_count} / {$limit.aliases}</span>
            </div>
        {/if}
    </div>
    <div class="mf-page-header-actions">
        <div class="mf-header-control">
            <form name="frmOverview" method="get" action="{$smarty.config.url_list_virtual}">
                {html_options name='domain' class='form-control' output=$domain_list values=$domain_list selected=$domain_selected onchange="this.form.submit();"}
                <input type="hidden" name="limit" value="0"/>
                <noscript><input class="mf-btn-secondary" type="submit" name="go" value="{$PALANG.go}"/></noscript>
            </form>
        </div>
        <div class="mf-header-control mf-search-inline">{#form_search#}</div>
        {if $tCanAddMailbox}
            <a href="{#url_create_mailbox#}&amp;domain={$fDomain|escape:"url"}" role="button" class="mf-btn-primary">
                <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                {$PALANG.add_mailbox}
            </a>
        {/if}
    </div>
</div>

<div class="mf-tab-strip">
    <div class="mf-tabs">
        {if $tab=='all'}<span class="mf-tab-active">{$PALANG.all}</span>
        {else}<a class="mf-tab" href="?domain={$smarty.get.domain}&amp;tab=all{$searchsuffix}">{$PALANG.all}</a>{/if}

        {if $tab=='mailbox'}<span class="mf-tab-active">{$PALANG.pOverview_mailbox_title}</span>
        {else}<a class="mf-tab" href="?domain={$smarty.get.domain}&amp;tab=mailbox{$searchsuffix}">{$PALANG.pOverview_mailbox_title}</a>{/if}

        {if $tab=='alias'}<span class="mf-tab-active">{$PALANG.pOverview_alias_title}</span>
        {else}<a class="mf-tab" href="?domain={$smarty.get.domain}&amp;tab=alias{$searchsuffix}">{$PALANG.pOverview_alias_title}</a>{/if}

        {if $boolconf_alias_domain}
            {if $tab=='alias_domain'}<span class="mf-tab-active">{$PALANG.pOverview_alias_domain_title}</span>
            {else}<a class="mf-tab" href="?domain={$smarty.get.domain}&amp;tab=alias_domain{$searchsuffix}">{$PALANG.pOverview_alias_domain_title}</a>{/if}
        {/if}
    </div>
    <div class="mf-page-header-actions">
        <a role="button" class="mf-btn-secondary" href="list.php?table=mailbox&amp;output=csv&amp;domain={$domain_selected}">
            <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            {$PALANG.download_csv}
        </a>
    </div>
</div>

<div class="mf-content">
    {*** Mailboxes first when viewing mailboxes or all ***}
    {if $tab=='mailbox' || $tab=='all'}
        <div id="mailboxes">
            {if $tab=='all'}
                <div class="mf-section-bar">
                    <h2 class="mf-section-heading">
                        {$PALANG.pOverview_mailbox_title}
                        <span class="mf-badge">{$tMailbox|count}</span>
                    </h2>
                    <div>{$nav_bar_mailbox.top}</div>
                </div>
            {elseif $nav_bar_mailbox.top}
                <div class="mf-section-bar">{$nav_bar_mailbox.top}</div>
            {/if}
            {assign var="colspan" value=9}
            {if $CONF.vacation_control_admin===YES}{assign var="colspan" value="`$colspan+1`"}{/if}
            {if $CONF.alias_control_admin===YES}{assign var="colspan" value="`$colspan+1`"}{/if}
            <div class="mf-table-wrapper">
                <div class="mf-table-scroll">
                    <table class="table table-hover" id="mailbox_table">
                        {if $tMailbox}
                            {include file="list-virtual_mailbox.tpl"}
                        {else}
                            <tbody><tr><td class="text-center" style="padding:24px;color:var(--mf-text-muted);">Nenhuma conta de email encontrada.</td></tr></tbody>
                        </table>
                        {/if}
                </div>
            </div>
            {if $nav_bar_mailbox.bottom}
                <div style="margin-top:10px;">{$nav_bar_mailbox.bottom}</div>
            {/if}
        </div>
    {/if}

    {*** Aliases ***}
    {if $tab=='alias' || $tab=='all'}
        {$nav_bar_alias.top}
        {include file="list-virtual_alias.tpl"}
        {$nav_bar_alias.bottom}
    {/if}

    {*** Domain Aliases ***}
    {if $boolconf_alias_domain}
        {if $tab=='alias_domain' || $tab=='all'}
            {include file="list-virtual_alias_domain.tpl"}
        {/if}
    {/if}

    {if $CONF.show_status===YES && $CONF.show_status_key===YES}
        <div class="mf-status-legend">
            {if $CONF.show_undeliverable===YES}
                <span class="mf-status-legend-item" title="{$PALANG.pStatus_undeliverable_tooltip|escape:"html"}">
                    <span style='background-color:{$CONF.show_undeliverable_color};border-radius:3px;'>{$CONF.show_status_text}</span>
                    {$PALANG.pStatus_undeliverable}
                </span>
                <span class="mf-status-legend-item" title="{$PALANG.pStatus_external_tooltip|escape:"html"}">
                    <span style='background-color:{$CONF.show_external_color};border-radius:3px;'>{$CONF.show_status_text}</span>
                    {$PALANG.pStatus_external}
                </span>
            {/if}
            {if $CONF.show_popimap===YES}
                <span class="mf-status-legend-item">
                    <span style='background-color:{$CONF.show_popimap_color};border-radius:3px;'>{$CONF.show_status_text}</span>
                    {$PALANG.pStatus_popimap}
                </span>
            {/if}
            {if $CONF.show_custom_domains|@count>0}
                {foreach from=$CONF.show_custom_domains item=item key=i}
                    <span class="mf-status-legend-item">
                        <span style='background-color:{$CONF.show_custom_colors[$i]};border-radius:3px;'>{$CONF.show_status_text}</span>
                        {$PALANG.pStatus_custom}{$item}
                    </span>
                {/foreach}
            {/if}
        </div>
    {/if}
</div>
