{strip}
    {include file="header.tpl"}
    {* Hide menu for some templates *}
    {if !in_array($smarty_template, ["login", "login-mfa", "password-recover", "password-change"])}
    {config_load file="menu.conf" section=$smarty_template}
        {if $authentication_has_role.user}
            {include file='users_menu.tpl'}
        {else}
            {include file='menu.tpl'}
        {/if}
    {/if}
    <main class="mf-main" role="main">
        {if $authentication_has_role.user && $CONF.motd_user}
            <div id="motd" class="mf-flash-motd">{$CONF.motd_user}</div>
        {elseif $authentication_has_role.global_admin && $CONF.motd_superadmin}
            <div id="motd" class="mf-flash-motd">{$CONF.motd_superadmin}</div>
        {elseif $authentication_has_role.admin && $CONF.motd_admin}
            <div id="motd" class="mf-flash-motd">{$CONF.motd_admin}</div>
        {/if}

        {include file='flash_error.tpl'}
        {if $smarty_template}
            {include file="$smarty_template.tpl"}
        {else}
            <div class="mf-content">
                <h3>Template not found</h3>
                <p>({$smarty.server.PHP_SELF|escape:"html"})</p>
            </div>
        {/if}
    </main>
    {include file='footer.tpl'}
{/strip}
