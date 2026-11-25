<div class="mf-page-header">
    <div class="mf-page-header-left">
        <p class="mf-eyebrow">Auditoria</p>
        <h1 class="mf-page-title">
            {if $domain_selected}
                {$PALANG.pViewlog_welcome|replace:"%s":$CONF.page_size} {$fDomain}
            {else}
                {$PALANG.pViewlog_welcome_all|replace:"%s":$CONF.page_size}
            {/if}
        </h1>
    </div>
    <div class="mf-page-header-actions">
        <div class="mf-header-control">
            <form name="frmOverview" method="post" action="">
                {html_options name='fDomain' class='form-control' output=$domain_list values=$domain_list selected=$domain_selected onchange="this.form.submit();"}
                <noscript><input class="mf-btn-secondary" type="submit" name="go" value="{$PALANG.go}"/></noscript>
            </form>
        </div>
    </div>
</div>

{if $tLog}
<div class="mf-content">
    <div class="mf-table-wrapper">
        <div class="mf-table-scroll">
            <table id="log_table" class="table">
                <thead>
                    {#tr_header#}
                        <th>{$PALANG.pViewlog_timestamp}</th>
                        <th>{$PALANG.admin}</th>
                        <th>{$PALANG.domain}</th>
                        <th>{$PALANG.pViewlog_action}</th>
                        <th>{$PALANG.pViewlog_data}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach from=$tLog item=item}
                        {assign var=log_data value=$item.data|truncate:45:"...":true}
                        {$smarty.config.tr_hilightoff}
                            <td nowrap="nowrap" style="color:var(--mf-text-muted);font-variant-numeric:tabular-nums;">{$item.timestamp}</td>
                            <td nowrap="nowrap">{$item.username}</td>
                            <td nowrap="nowrap"><strong>{$item.domain}</strong></td>
                            <td nowrap="nowrap"><span class="mf-badge-solid">{$item.action}</span></td>
                            <td>
                                <details>
                                    <summary>{$log_data}</summary>
                                    <div style="overflow-wrap: anywhere;margin-top:6px;">{$item.data}</div>
                                </details>
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
    </div>

    <div class="mf-pagination-bar">
        {if $number_of_pages < 6}
            <div class="btn-group" role="group">
                {for $i=1 to $number_of_pages}
                    <button type="button" onclick="go2page({$i})" class="btn btn-secondary">{$i}</button>
                {/for}
            </div>
        {elseif $page_number > 3 && $page_number < ($number_of_pages - 2)}
            <div class="btn-group" role="group">
                <button type="button" onclick="go2page(1)" class="btn btn-secondary">1</button>
            </div>
            <div class="btn-group" role="group">
                <button type="button" onclick="go2page({$page_number-1})" class="btn btn-secondary">{$page_number-1}</button>
                <button type="button" onclick="go2page({$page_number})" class="btn btn-primary">{$page_number}</button>
                <button type="button" onclick="go2page({$page_number+1})" class="btn btn-secondary">{$page_number+1}</button>
            </div>
            <div class="btn-group" role="group">
                <button type="button" onclick="go2page({$number_of_pages})" class="btn btn-secondary">{$number_of_pages}</button>
            </div>
        {else}
            {if $page_number < 4}
                <div class="btn-group" role="group">
                    <button type="button" onclick="go2page(1)" class="btn btn-secondary">1</button>
                    <button type="button" onclick="go2page(2)" class="btn btn-secondary">2</button>
                    <button type="button" onclick="go2page(3)" class="btn btn-secondary">3</button>
                    <button type="button" onclick="go2page(4)" class="btn btn-secondary">4</button>
                </div>
                <div class="btn-group" role="group">
                    <button type="button" onclick="go2page({$number_of_pages})" class="btn btn-secondary">{$number_of_pages}</button>
                </div>
            {else}
                <div class="btn-group" role="group">
                    <button type="button" onclick="go2page(1)" class="btn btn-secondary">1</button>
                </div>
                <div class="btn-group" role="group">
                    <button type="button" onclick="go2page({$number_of_pages-3})" class="btn btn-secondary">{$number_of_pages-3}</button>
                    <button type="button" onclick="go2page({$number_of_pages-2})" class="btn btn-secondary">{$number_of_pages-2}</button>
                    <button type="button" onclick="go2page({$number_of_pages-1})" class="btn btn-secondary">{$number_of_pages-1}</button>
                    <button type="button" onclick="go2page({$number_of_pages})" class="btn btn-secondary">{$number_of_pages}</button>
                </div>
            {/if}
        {/if}

        <div class="btn-group" role="group">
            <div class="dropdown">
                <button class="btn btn-secondary dropdown-toggle" type="button" data-toggle="dropdown">Página <span class="caret"></span></button>
                <ul class="dropdown-menu dropdown-menu-right" style="max-height: 200px; overflow: auto">
                    {for $i=1 to $number_of_pages}
                        <li><a onclick="go2page({$i}); return false;" href="#">{$i}</a></li>
                    {/for}
                </ul>
            </div>
        </div>
    </div>
</div>
{/if}

<script>
    function go2page(page) {
        window.location.href = '{$url|escape:"javascript"}?page=' + encodeURIComponent(page) + '&fDomain=' + encodeURIComponent('{$fDomain|escape:"javascript"}');
    }
</script>
