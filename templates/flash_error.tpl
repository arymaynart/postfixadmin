<!-- {$smarty.template} -->
{strip}
    {if isset($smarty.session.flash)}
        {if isset($smarty.session.flash.info)}
            <div class="mf-flash-success" role="alert">
                <ul class="flash-info">
                    {foreach from=$smarty.session.flash.info item=msg}
                        <li>{$msg|escape:html}</li>
                    {/foreach}
                </ul>
            </div>
        {/if}
        {if isset($smarty.session.flash.error)}
            <div class="mf-flash-error" role="alert">
                <ul class="flash-error">
                    {foreach from=$smarty.session.flash.error item=msg}
                        <li>{$msg|escape:html}</li>
                    {/foreach}
                </ul>
            </div>
        {/if}
    {/if}
{/strip}
