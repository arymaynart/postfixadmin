{strip}
    {include file="header.tpl"}
    {assign var="mf_auth_page" value=in_array($smarty_template, ["login", "login-mfa", "password-recover", "password-change"])}
    {* Hide menu for some templates *}
    {if !$mf_auth_page}
    {config_load file="menu.conf" section=$smarty_template}
        {if $authentication_has_role.user}
            {include file='users_menu.tpl'}
        {else}
            {include file='menu.tpl'}
        {/if}
    {else}
        {include file='auth_background.tpl'}
    {/if}
    <main class="mf-main" role="main">
        {if $authentication_has_role.user && $CONF.motd_user}
            <div id="motd" class="mf-flash-motd" data-mf-flash="sticky">{$CONF.motd_user}</div>
        {elseif $authentication_has_role.global_admin && $CONF.motd_superadmin}
            <div id="motd" class="mf-flash-motd" data-mf-flash="sticky">{$CONF.motd_superadmin}</div>
        {elseif $authentication_has_role.admin && $CONF.motd_admin}
            <div id="motd" class="mf-flash-motd" data-mf-flash="sticky">{$CONF.motd_admin}</div>
        {/if}

        {* Notices: glued to the title bar; on the login pages (no title bar) they sit on top of the footer *}
        {if !$mf_auth_page}
            {include file='flash_error.tpl'}
        {/if}
        {if $smarty_template}
            {include file="$smarty_template.tpl"}
        {else}
            <div class="mf-content">
                <h3>Template not found</h3>
                <p>({$smarty.server.PHP_SELF|escape:"html"})</p>
            </div>
        {/if}
    </main>
    {if $mf_auth_page}
        {include file='flash_error.tpl'}
    {/if}
    {include file='footer.tpl'}
{/strip}
