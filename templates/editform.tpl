{if $table == 'domain'}{assign var="mf_section_label" value=$PALANG.pAdminMenu_domain}
{elseif $table == 'admin'}{assign var="mf_section_label" value=$PALANG.pAdminMenu_admin}
{elseif $table == 'mailbox'}{assign var="mf_section_label" value=$PALANG.pOverview_mailbox_title}
{elseif $table == 'alias'}{assign var="mf_section_label" value=$PALANG.pOverview_alias_title}
{elseif $table == 'aliasdomain'}{assign var="mf_section_label" value=$PALANG.pOverview_alias_domain_title}
{elseif $table == 'fetchmail'}{assign var="mf_section_label" value=$PALANG.pMenu_fetchmail}
{elseif $table == 'dkim'}{assign var="mf_section_label" value=$PALANG.pMenu_dkim}
{elseif $table == 'dkimsigning'}{assign var="mf_section_label" value=$PALANG.pMenu_dkim_signing}
{elseif $table == 'adminpassword'}{assign var="mf_section_label" value=$PALANG.pMenu_security}
{else}{assign var="mf_section_label" value=$table|capitalize}{/if}

<div class="mf-page-header">
    <div class="mf-page-header-left">
        <p class="mf-eyebrow">Cadastro · {$mf_section_label}</p>
        <h1 class="mf-page-title">{$formtitle}</h1>
    </div>
    <div class="mf-page-header-actions">
        <button class="mf-btn-primary" type="submit" name="submit" form="pfa-edit-form">
            <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
            {$submitbutton}
        </button>
    </div>
</div>

<div class="mf-content">
    <div class="mf-form-wrap">
        <form id="pfa-edit-form" name="edit_{$table}" method="post" action="" class="form-horizontal">
            <div id="edit_form" class="mf-form-sheet">
                <div class="mf-form-sheet-body enable-asterisk">
                    <input class="flat" type="hidden" name="table" value="{$table}"/>
                    <input class="flat" type="hidden" name="token" value="{$smarty.session.PFA_token|escape:"url"}"/>

                    {foreach key=key item=field from=$struct}
                        {if $field.display_in_form == 1}
                            {if $table == 'foo' && $key == 'bar'}
                                <div class="form-group">Special handling (complete table row) for {$table} / {$key}</div>
                            {else}
                                <div class="form-group {if $fielderror.{$key}}has-error{/if}">
                                    <label class="col-md-4 col-sm-4 control-label" for="{$key}">{$field.label}</label>
                                    <div class="col-md-8 col-sm-8">
                                        {if $field.editable == 0}
                                            <p class="form-control-static">
                                                {if $field.type == 'enma'}
                                                    {$struct.{$key}.options.{$value_{$key}}}
                                                {else}
                                                    {$value_{$key}}
                                                {/if}
                                            </p>
                                        {else}
                                            {if $table == 'foo' && $key == 'bar'}
                                                Special handling (td content) for {$table} / {$key}
                                            {elseif $field.type == 'bool'}
                                                <div class="checkbox"><label>
                                                    <input type="checkbox" value='1'
                                                           name="value[{$key}]"{if {$value_{$key}} == 1} checked="checked"{/if}/>
                                                </label></div>
                                            {elseif $field.type == 'enum'}
                                                <select class="form-control" name="value[{$key}]" id="{$key}">
                                                    {html_options output=$struct.{$key}.options values=$struct.{$key}.options selected=$value_{$key}}
                                                </select>
                                            {elseif $field.type == 'enma'}
                                                <select class="form-control" name="value[{$key}]" id="{$key}">
                                                    {html_options options=$struct.{$key}.options selected=$value_{$key}}
                                                </select>
                                            {elseif $field.type == 'list'}
                                                <input type="text" class="form-control" style="margin-bottom: 14px;"
                                                       id="id_searchDomains" onkeyup="searchDomains()"
                                                       placeholder="Filtrar domínios..." title="Filtrar domínios">
                                                <ul id="domainsList" name="value[{$key}][]"
                                                    style="max-height: 250px; overflow: auto; padding-left: 4px;">
                                                    {foreach from=$struct.{$key}.options item=domain}
                                                        <li style="list-style-type: none; padding: 3px 0;">
                                                            {assign var=flag value=0}
                                                            {foreach from=$value_{$key} item=selectedDomain}
                                                                {if $domain == $selectedDomain }
                                                                    <input type="checkbox" checked name="value[{$key}][]"
                                                                           value="{$domain|escape:"html"}" id="{$domain|escape:"html"}_id"/>
                                                                    <label for="{$domain|escape:"html"}_id" style="font-weight:500;margin-left:6px;">{$domain|escape:"html"}</label>
                                                                    {assign var=flag value=$flag+1}
                                                                {/if}
                                                            {/foreach}
                                                            {if $flag == 0 }
                                                                <input type="checkbox" name="value[{$key}][]" value="{$domain|escape:"html"}"
                                                                       id="{$domain|escape:"html"}_id"/>
                                                                <label for="{$domain|escape:"html"}_id" style="font-weight:500;margin-left:6px;">{$domain|escape:"html"}</label>
                                                            {/if}
                                                        </li>
                                                    {/foreach}
                                                </ul>
                                            {elseif $field.type == 'pass' || $field.type == 'b64p'}
                                                <input class="form-control" type="password" name="value[{$key}]"
                                                       {if $key == 'password' || $key == 'password2'}autocomplete="new-password"{/if}/>
                                            {elseif $field.type == 'txtl'}
                                                <textarea class="form-control" rows="8" cols="35"
                                                          name="value[{$key}]">{foreach key=key2 item=field2 from=$value_{$key}}{$field2}&#10;{/foreach}</textarea>
                                            {elseif $field.type == 'txta'}
                                                <textarea class="form-control" rows="8" cols="35"
                                                          name="value[{$key}]">{$value_{$key}}</textarea>
                                            {else}
                                                <input class="form-control" type="text" name="value[{$key}]"
                                                       value="{$value_{$key}}"/>
                                            {/if}
                                        {/if}

                                        {if $table == 'foo' && $key == 'bar'}
                                            <span class="help-block">Special handling (td content) for {$table} / {$key}</span>
                                        {else}
                                            {if $fielderror.{$key}}
                                                <span class="help-block">{$fielderror.{$key}}</span>
                                            {elseif $field.desc}
                                                <span class="help-block">{$field.desc}</span>
                                            {/if}
                                        {/if}
                                    </div>
                                </div>
                            {/if}
                        {/if}
                    {/foreach}
                </div>
                <div class="mf-form-sheet-footer">
                    <button class="mf-btn-primary" type="submit" name="submit">
                        <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                        {$submitbutton}
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

{literal}<script type="text/javascript">
    function searchDomains() {
        var input = document.getElementById("id_searchDomains").value.toLowerCase();
        var ul = document.getElementById("domainsList");
        var li = ul.getElementsByTagName("li");
        for (var i = 0; i < li.length; i++) {
            var label = li[i].getElementsByTagName("label")[0];
            var domain = label ? label.textContent : "";
            li[i].style.display = domain.toLowerCase().indexOf(input) > -1 ? "" : "none";
        }
    }
</script>{/literal}
