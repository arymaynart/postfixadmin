{assign var="is_embedded" value=($smarty_template == 'list-virtual')}
{assign var="tmpdomain" value=""}
{if isset($fDomain)}
    {assign var="tmpdomain" value="&amp;domain={$fDomain|escape:url}"}
{/if}
{if $msg.list_header}
    {assign var="mf_list_title" value=$PALANG.{$msg.list_header}}
{elseif $table == 'domain'}
    {assign var="mf_list_title" value=$PALANG.pAdminMenu_domain}
{elseif $table == 'admin'}
    {assign var="mf_list_title" value=$PALANG.pAdminMenu_admin}
{elseif $table == 'alias'}
    {assign var="mf_list_title" value=$PALANG.pOverview_alias_title}
{elseif $table == 'aliasdomain'}
    {assign var="mf_list_title" value=$PALANG.pOverview_alias_domain_title}
{elseif $table == 'fetchmail'}
    {assign var="mf_list_title" value=$PALANG.pMenu_fetchmail}
{elseif $table == 'dkim'}
    {assign var="mf_list_title" value=$PALANG.pMenu_dkim}
{elseif $table == 'dkimsigning'}
    {assign var="mf_list_title" value=$PALANG.pMenu_dkim_signing}
{else}
    {assign var="mf_list_title" value=$table|capitalize}
{/if}

{if !$is_embedded}
<div class="mf-page-header">
    <div class="mf-page-header-left">
        <p class="mf-eyebrow">Administração</p>
        <h1 class="mf-page-title">
            {$mf_list_title}
            <span class="mf-badge">{$RAW_items|count}</span>
        </h1>
    </div>
    <div class="mf-page-header-actions">
        {if ($admin_list|count > 1)}
            <div class="mf-header-control">
                <form name="frmOverview" method="post" action="">
                    {html_options name='username' class='form-control' output=$admin_list values=$admin_list selected=$admin_selected onchange="this.form.submit();"}
                    <noscript><input class="mf-btn-secondary" type="submit" name="go" value="{$PALANG.go}"/></noscript>
                </form>
            </div>
        {/if}
        {if $msg.show_simple_search}
            <div class="mf-header-control mf-search-inline">
                {#form_search#}
            </div>
        {/if}
        <a href="list.php?table={$table|escape:"url"}&amp;output=csv&amp;domain={$domain_selected|escape:"url"}" role="button" class="mf-btn-secondary">
            <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            {$PALANG.download_csv}
        </a>
        {if $msg.can_create}
            <a href="edit.php?table={$table|escape:"url"}{$tmpdomain}" role="button" class="mf-btn-primary">
                <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                {$PALANG.{$formconf.create_button}}
            </a>
        {/if}
    </div>
</div>
<div id="{$id_div}" class="mf-content">
{else}
<div id="{$id_div}" class="mf-embedded-section">
    <div class="mf-section-bar">
        <h2 class="mf-section-heading">
            {$mf_list_title}
            <span class="mf-badge">{$RAW_items|count}</span>
        </h2>
        <div class="mf-page-header-actions">
            <a href="list.php?table={$table|escape:"url"}&amp;output=csv&amp;domain={$domain_selected|escape:"url"}" role="button" class="mf-btn-secondary">
                <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                {$PALANG.download_csv}
            </a>
            {if $msg.can_create}
                <a href="edit.php?table={$table|escape:"url"}{$tmpdomain}" role="button" class="mf-btn-primary">
                    <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    {$PALANG.{$formconf.create_button}}
                </a>
            {/if}
        </div>
    </div>
{/if}

    {if $msg.show_simple_search && ($search|count > 0)}
        <div class="mf-search-chips">
            <span>{$PALANG.searchparams}</span>
            {foreach key=key item=field from=$search}
                <span class="mf-badge-solid">{if $struct.$key.label}{$struct.$key.label}{else}{$key}{/if} {if isset($searchmode.$key)}{$searchmode.$key}{else}={/if} {$field}</span>
            {/foreach}
            <a href="list.php?table={$table|escape:"url"}&amp;reset_search=1">Limpar filtro ×</a>
        </div>
    {/if}

    <div class="mf-table-wrapper">
        <div class="{if $table == 'domain'}domain-list-scroll{else}mf-table-scroll{/if}">
            <table class="table table-hover" id='admin_table'>
                <thead>
                <tr class="header">
                    {foreach key=key item=field from=$struct}
                        {if $field.display_in_list == 1 && $field.label}
                            <th class="list-col-{$key}">{$field.label}</th>
                        {/if}
                    {/foreach}
                    <th class="list-col-action">&nbsp;</th>
                    <th class="list-col-action">&nbsp;</th>
                </tr>
                </thead>
                <tbody>
                {foreach key=raw_itemkey from=$RAW_items item=RAW_item}
                {assign var="itemkey" value=$raw_itemkey|htmlentities_no_double_encode}
                {assign var="item" value=$items[$itemkey]}
                <tr>
                    {foreach key=key item=field from=$struct}
                    {if $field.display_in_list == 1 && $field.label}

                    {if $field.linkto != '' && ($item.$id_field != '' || $item.$id_field > 0) }
                        {assign "linkto" "{$field.linkto|replace:'%s':{$item.$id_field|escape:url}}"}
                        {assign "linktitle" ""}
                        {if $table == 'domain' && $key == 'domain'}
                            {if isset($struct.maxquota) && $struct.maxquota.label == '' && isset($item.maxquota)}
                                {assign "linktitle" "{$PALANG.pOverview_get_quota}: {$item.maxquota} MB"}
                            {/if}
                            {if isset($struct.password_expiry) && $struct.password_expiry.label == '' && isset($item.password_expiry)}
                                {if $linktitle != ''}{assign "linktitle" "{$linktitle}&#10;"}{/if}
                                {assign "linktitle" "{$linktitle}{$PALANG.password_expiration}: {$item.password_expiry}"}
                            {/if}
                        {/if}
                        {if $linktitle != ''}
                            {assign "linktext" "<a href='{$linkto}' title='{$linktitle}'>{$item.{$key}}</a>"}
                        {else}
                            {assign "linktext" "<a href='{$linkto}'>{$item.{$key}}</a>"}
                        {/if}
                    {else}
                        {assign "linktext" $item.$key}
                    {/if}

                    {if $table == 'foo' && $key == 'bar'}
                    <td>Special handling (complete table row) for {$table} / {$key}</td>
                    {else}
                    <td class="list-col-{$key}">
                        {if $table == 'foo' && $key == 'bar'}
                        Special handling (td content) for {$table} / {$key}
                        {elseif $table == 'aliasdomain' && $key == 'target_domain' && $struct.target_domain.linkto == 'target'}
                        <a href="list-virtual.php?domain={$item.target_domain|escape:"quotes"}">{$item.target_domain}</a>
                        {elseif $key == 'active'}
                        {if $item._can_edit}
                            <a class="pfa-action-btn {if ($item.active==0)}pfa-btn-active-off{else}pfa-btn-active-on{/if}" title="{$field.label}: {$item._active}" aria-label="{$field.label}: {$item._active}"
                               href="{#url_editactive#}{$table}&amp;id={$RAW_item.$id_field|escape:"url"}&amp;active={if ($item.active==0)}1{else}0{/if}&amp;token={$smarty.session.PFA_token|escape:"url"}">
                                {if $item._active == $PALANG['YES']}
                                    <svg class="pfa-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="9"/><path d="m9 12 2 2 4-4"/></svg>
                                {else}
                                    <svg class="pfa-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="9"/><line x1="6" y1="18" x2="18" y2="6"/></svg>
                                {/if}
                            </a>
                        {else}
                            {$item._active}
                        {/if}
                        {elseif $field.type == 'bool'}
                        {assign "tmpkey" "_{$key}"}{$item.{$tmpkey}}
                        {elseif $field.type == 'list'}
                        {foreach key=key2 item=field2 from=$item.$key}{$field2}<br>{/foreach}
                        {elseif $field.type == 'pass'}
                        (hidden)
                        {elseif $field.type == 'quot'}
                        {assign "tmpkey" "_{$key}_percent"}

                        {if $item[$tmpkey] > $CONF.quota_level_high_pct}
                            {assign var="quota_level" value="high"}
                        {elseif $item[$tmpkey] > $CONF.quota_level_med_pct}
                            {assign var="quota_level" value="mid"}
                        {else}
                            {assign var="quota_level" value="low"}
                        {/if}
                        <div class="quota_bar{if $item[$tmpkey] <= -1} quota_no_border{/if}">
                        {if $item[$tmpkey] > -1}
                            <span class="quota_fill quota_{$quota_level}" style="width:{$item[$tmpkey]}%;"></span>
                            <span class="quota_label quota_text_{$quota_level}">{$linktext}</span>
                        {else}
                            <span class="quota_label">{$linktext}</span>
                        {/if}
                        </div>
                        {elseif $field.type == 'txtl'}
                        {foreach key=key2 item=field2 from=$item.$key}{$field2}<br>{/foreach}
                        {elseif $field.type == 'html'}
                        {$RAW_item.$key}
                        {else}
                        {$linktext}
                        {/if}
                    </td>
                    {/if}
                    {/if}
                    {/foreach}

                    <td class="list-col-action">{if $item._can_edit}
                        <a class="pfa-action-btn pfa-btn-edit" title="{$PALANG.edit}" aria-label="{$PALANG.edit}"
                           href="edit.php?table={$table|escape:"url"}&amp;edit={$RAW_item.$id_field|escape:"url"}">
                            <svg class="pfa-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/><path d="m15 5 4 4"/></svg>
                        </a>
                    {else}&nbsp;{/if}</td>
                    <td class="list-col-action">{if $item._can_delete}
                        <form method="post" action="{#url_delete#}">
                            <input type="hidden" name="table" value="{$table}">
                            <input type="hidden" name="delete" value="{$item.$id_field}">
                            <input type="hidden" name="token" value="{$smarty.session.PFA_token|escape:"quotes"}">
                            <button class="pfa-action-btn pfa-btn-delete" title="{$PALANG.del}" aria-label="{$PALANG.del}"
                                    onclick="return confirm('{$PALANG.{$msg.confirm_delete}|replace:'%s':{$RAW_item.$id_field|escape:'javascript'|escape:'html'}}')">
                                <svg class="pfa-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>
                            </button>
                        </form>
                    {else}&nbsp;{/if}</td>
                </tr>
                {/foreach}
                </tbody>
            </table>
        </div>
    </div>
</div>
