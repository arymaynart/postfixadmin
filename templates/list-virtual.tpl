{assign var="file" value=$smarty.config.url_list_virtual}
{if isset($search._)}
    {assign var="searchsuffix" value="&amp;search[_]={$search._|escape:"url"}"}
{else}
    {assign var="searchsuffix" value=""}
{/if}
{assign var="tab_domain_url" value=$smarty.get.domain|default:$fDomain|escape:"url"}

{if $tab=='alias'}
    {assign var="mf_tab_title" value=$PALANG.pOverview_alias_title}
{elseif $tab=='alias_domain'}
    {assign var="mf_tab_title" value=$PALANG.pOverview_alias_domain_title}
{else}
    {assign var="mf_tab_title" value=$PALANG.pOverview_mailbox_title}
{/if}

<div id="overview" class="mf-page-header">
    <div class="mf-page-header-left">
        <p class="mf-eyebrow">{$PALANG.pAdminMenu_virtual} · {$PALANG.pOverview_domain_label}</p>
        <h1 class="mf-page-title">
            {if isset($search._)}
                {$PALANG.pSearch_welcome} {$search._}
            {else}
                {$fDomain}
            {/if}
        </h1>
        {if !isset($search._)}
            <div class="mf-header-meta">
                <span class="mf-badge">{$PALANG.pOverview_mailbox_title}: {$limit.mailbox_count} / {$limit.mailboxes}</span>
                <span class="mf-badge-solid">{$PALANG.aliases}: {$limit.alias_count} / {$limit.aliases}</span>
            </div>
        {/if}
    </div>
</div>

{* Filters: the tabs show one table at a time; domain and search live in the same bar *}
<div class="mf-tab-strip mf-filter-bar">
    <nav class="mf-tabs" aria-label="{$PALANG.pAdminMenu_virtual}">
        {if $tab=='mailbox'}<span class="mf-tab-active" aria-current="page">{$PALANG.pOverview_mailbox_title} <span class="mf-tab-count">{$tMailbox|count}</span></span>
        {else}<a class="mf-tab" href="?domain={$tab_domain_url}&amp;tab=mailbox{$searchsuffix}">{$PALANG.pOverview_mailbox_title} <span class="mf-tab-count">{$tMailbox|count}</span></a>{/if}

        {if $tab=='alias'}<span class="mf-tab-active" aria-current="page">{$PALANG.pOverview_alias_title} <span class="mf-tab-count">{$tAlias|count}</span></span>
        {else}<a class="mf-tab" href="?domain={$tab_domain_url}&amp;tab=alias{$searchsuffix}">{$PALANG.pOverview_alias_title} <span class="mf-tab-count">{$tAlias|count}</span></a>{/if}

        {if $boolconf_alias_domain}
            {if $tab=='alias_domain'}<span class="mf-tab-active" aria-current="page">{$PALANG.pOverview_alias_domain_title} <span class="mf-tab-count">{$tAliasDomains|count}</span></span>
            {else}<a class="mf-tab" href="?domain={$tab_domain_url}&amp;tab=alias_domain{$searchsuffix}">{$PALANG.pOverview_alias_domain_title} <span class="mf-tab-count">{$tAliasDomains|count}</span></a>{/if}
        {/if}
    </nav>
    <div class="mf-filter-controls">
        <form name="frmOverview" method="get" action="{$smarty.config.url_list_virtual}" class="mf-filter-domain">
            <label class="sr-only" for="mf-filter-domain-select">{$PALANG.pOverview_domain_label}</label>
            {html_options name='domain' id='mf-filter-domain-select' class='form-control' output=$domain_list values=$domain_list selected=$domain_selected onchange="this.form.submit();"}
            <input type="hidden" name="limit" value="0"/>
            <input type="hidden" name="tab" value="{$tab|escape:"html"}"/>
            <noscript><input class="mf-btn-secondary" type="submit" name="go" value="{$PALANG.go}"/></noscript>
        </form>
        <form name="search" method="post" action="list-virtual.php?tab={$tab|escape:"url"}" class="mf-filter-search" role="search">
            <label class="sr-only" for="mf-filter-search-input">{$PALANG.pOverview_search_label}</label>
            <svg class="mf-filter-search-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <input class="form-control" id="mf-filter-search-input" type="search" name="search[_]" placeholder="{$PALANG.pOverview_search_label}" value="{if isset($search._)}{$search._|escape:"html"}{/if}"/>
        </form>
    </div>
</div>

<div class="mf-content">
    {*** Mailboxes ***}
    {if $tab=='mailbox'}
        <div id="mailboxes" class="mf-table-wrapper mf-table-card">
            <div class="mf-table-card-header">
                <h2 class="mf-table-card-title">
                    {$PALANG.pOverview_mailbox_title}
                    <span class="mf-badge">{$tMailbox|count}</span>
                </h2>
                <div class="mf-page-header-actions">
                    <a role="button" class="mf-btn-secondary" href="list.php?table=mailbox&amp;output=csv&amp;domain={$domain_selected|escape:"url"}">
                        <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                        {$PALANG.download_csv}
                    </a>
                    {if $tCanAddMailbox}
                        <a href="{#url_create_mailbox#}&amp;domain={$fDomain|escape:"url"}" role="button" class="mf-btn-primary">
                            <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                            {$PALANG.add_mailbox}
                        </a>
                    {/if}
                </div>
            </div>
            {if $nav_bar_mailbox.top}
                <div class="mf-table-card-nav">{$nav_bar_mailbox.top}</div>
            {/if}
            {assign var="colspan" value=9}
            {if $CONF.vacation_control_admin===YES}{assign var="colspan" value="`$colspan+1`"}{/if}
            {if $CONF.alias_control_admin===YES}{assign var="colspan" value="`$colspan+1`"}{/if}
            <div class="mf-table-scroll">
                <table class="table table-hover" id="mailbox_table">
                    {if $tMailbox}
                        {include file="list-virtual_mailbox.tpl"}
                    {else}
                        <tbody><tr><td class="text-center mf-table-empty">Nenhum e-mail encontrado.</td></tr></tbody>
                    </table>
                    {/if}
            </div>
            {if $nav_bar_mailbox.bottom}
                <div class="mf-table-card-nav">{$nav_bar_mailbox.bottom}</div>
            {/if}
        </div>
    {/if}

    {*** Aliases ***}
    {if $tab=='alias'}
        {$nav_bar_alias.top}
        {include file="list-virtual_alias.tpl"}
        {$nav_bar_alias.bottom}
    {/if}

    {*** Domain Aliases ***}
    {if $boolconf_alias_domain}
        {if $tab=='alias_domain'}
            {include file="list-virtual_alias_domain.tpl"}
        {/if}
    {/if}

    {if $tab!='alias_domain' && $CONF.show_status===YES && $CONF.show_status_key===YES}
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
