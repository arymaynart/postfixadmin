{if isset($search._)}
    {assign var="search" value=$search._}
{else}
    {assign var="search" value=''}
{/if}

	<thead>
	{#tr_header#}
		{if $CONF.show_status===YES}<th></th>{/if}
		<th>{$PALANG.pOverview_mailbox_username}</th>
		{if $display_mailbox_aliases==true}
			<th class="list-col-forward">{$PALANG.pOverview_forward_col}</th>
		{/if}
		<th>{$PALANG.name}</th>
		{if $CONF.quota===YES}<th>{$PALANG.pOverview_mailbox_quota}</th>{/if}
		<th>{$PALANG.last_modified}</th>
		{if $password_expiration}<th class="text-center">{$PALANG.password}</th>{/if}
		<th class="list-col-active">{$PALANG.active}</th>
		{if $CONF.smtp_active_flag===YES}<th class="list-col-active">{$PALANG.smtp_active}</th>{/if}
		{assign var="colspan" value="`$colspan-6`"}
		<th colspan="{$colspan}">&nbsp;</th>
	</tr>
	</thead>
	<tbody>
	{foreach from=$tMailbox item=item key=i}
		<tr>
			{if $CONF.show_status===YES}
				<td>{$gen_show_status_mailbox[$i]}</td>
			{/if}
			<td>
			{if $search eq ""}
				{$item.username}
			{else}
				{$item.username|replace:$search:"<span class='searchresult'>$search</span>"}
			{/if}
			</td>
			{if $display_mailbox_aliases==true}
				<td class="list-col-forward">
				{if empty($item.goto_other)}
					<span class="mf-forward-none">{$PALANG.pOverview_forward_none}</span>
				{else}
					<span class="mf-forward-mode{if $item.goto_mailbox != 1} mf-forward-mode--only{/if}">{if $item.goto_mailbox == 1}{$PALANG.pOverview_forward_copy}{else}{$PALANG.pOverview_forward_only}{/if}</span>
					{foreach from=$item.goto_other item=item2 key=j}
						<span class="mf-forward-dest">{if $search eq ""}{$item2}{else}{$item2|replace:$search:"<span class='searchresult'>$search</span>"}{/if}</span>
					{/foreach}
				{/if}
				</td>
			{/if}
			<td>{$item.name}</td>
			{if $CONF.quota===YES}
				<td>
				{if $item.quota==0}
					{$PALANG.pOverview_unlimited}
				{elseif $item.quota<0}
					{$PALANG.pOverview_disabled}
				{else}
					{if $boolconf_used_quotas}
						{assign var="quota_level" value="low"}
						{if $divide_quota.percent[$i] > $CONF.quota_level_high_pct}
							{assign var="quota_level" value="high"}
						{elseif $divide_quota.percent[$i] > $CONF.quota_level_med_pct}
							{assign var="quota_level" value="mid"}
						{/if}
						<div class="quota_bar">
							<span class="quota_fill quota_{$quota_level}" style="width:{$divide_quota.percent[$i]}%;"></span>
							<span class="quota_label quota_text_{$quota_level}">{$divide_quota.current[$i]} / {$divide_quota.quota[$i]}</span>
						</div>
					{else}
						{$divide_quota.quota[$i]}
					{/if}
				{/if}
				</td>
			{/if}
			<td>{$item.modified}</td>
			{if $password_expiration}
				<td class="text-center">
					{if $item.password_expiration_never}
						<span class="glyphicon glyphicon-lock text-muted" role="img" title="{$password_expiration_never_label}" aria-label="{$password_expiration_never_label}"></span>
					{elseif $item.password_expiration_expired}
						<span class="glyphicon glyphicon-lock text-danger" role="img" title="{$PALANG.pStatus_expired}{$item.password_expiration}" aria-label="{$PALANG.pStatus_expired}{$item.password_expiration}"></span>
					{else}
						<span class="glyphicon glyphicon-lock text-success" role="img" title="{$password_expiration_on_label} {$item.password_expiration}" aria-label="{$password_expiration_on_label} {$item.password_expiration}"></span>
					{/if}
				</td>
			{/if}
			<td class="list-col-active"><a class="pfa-action-btn {if ($item.active==0)}pfa-btn-active-off{else}pfa-btn-active-on{/if}" title="{$PALANG.active}: {if $item.active==1}{$PALANG.YES}{else}{$PALANG.NO}{/if}" aria-label="{$PALANG.active}: {if $item.active==1}{$PALANG.YES}{else}{$PALANG.NO}{/if}" href="{#url_editactive#}mailbox&amp;id={$item.username|escape:"url"}&amp;active={if ($item.active==0)}1{else}0{/if}&amp;token={$smarty.session.PFA_token|escape:"url"}"
				>{if $item.active==1}<svg class="pfa-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="9"/><path d="m9 12 2 2 4-4"/></svg>{else}<svg class="pfa-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="9"/><line x1="6" y1="18" x2="18" y2="6"/></svg>{/if}</a></td>
                        {if $CONF.smtp_active_flag===YES}
				<td class="list-col-active"><a class="pfa-action-btn {if ($item.smtp_active==0)}pfa-btn-active-off{else}pfa-btn-active-on{/if}" title="{$PALANG.smtp_active}: {if $item.smtp_active==1}{$PALANG.YES}{else}{$PALANG.NO}{/if}" aria-label="{$PALANG.smtp_active}: {if $item.smtp_active==1}{$PALANG.YES}{else}{$PALANG.NO}{/if}" href="{#url_editactive#}mailbox&amp;id={$item.username|escape:"url"}&amp;active={if ($item.smtp_active==0)}1{else}0{/if}&amp;field=smtp_active&amp;token={$smarty.session.PFA_token|escape:"url"}"
				>{if $item.smtp_active==1}<svg class="pfa-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="9"/><path d="m9 12 2 2 4-4"/></svg>{else}<svg class="pfa-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="9"/><line x1="6" y1="18" x2="18" y2="6"/></svg>{/if}</a></td>
			{/if}
			{if $CONF.vacation_control_admin===YES && $CONF.vacation===YES}
				{if $item.v_active!==-1}
					{if $item.v_active==1}
						{assign var="v_active" value=$PALANG.pOverview_vacation_edit}
					{else}
						{assign var="v_active" value=$PALANG.pOverview_vacation_option}
					{/if}
					<td class="list-col-action"><a class="pfa-action-btn {if ($item.v_active==0)}pfa-btn-vacation-off{else}pfa-btn-vacation-on{/if}" title="{$v_active}" aria-label="{$v_active}" href="vacation.php?username={$item.username|escape:"url"}"><svg class="pfa-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="9"/><polyline points="12 7 12 12 15 15"/></svg></a></td>
				{/if}
			{else}
					<td class="list-col-spacer"></td>
			{/if}
			{assign var="edit_aliases" value=0}
			{if $authentication_has_role.global_admin!==true && $CONF.alias_control_admin===YES}{assign var="edit_aliases" value=1}{/if}
			{if $authentication_has_role.global_admin==true && $CONF.alias_control===YES}{assign var="edit_aliases" value=1}{/if}
			{if $edit_aliases==1}
				<td class="list-col-action"><a class="pfa-action-btn pfa-btn-alias" title="{$PALANG.pForward_button}" aria-label="{$PALANG.pForward_button}" href="edit.php?table=alias&amp;edit={$item.username|escape:"url"}"><svg class="pfa-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><polyline points="15 14 20 9 15 4"/><path d="M4 20v-7a4 4 0 0 1 4-4h12"/></svg></a></td>
			{/if}
			<td class="list-col-action"><a class="pfa-action-btn pfa-btn-edit" title="{$PALANG.edit}" aria-label="{$PALANG.edit}" href="edit.php?table=mailbox&amp;edit={$item.username|escape:"url"}"><svg class="pfa-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/><path d="m15 5 4 4"/></svg></a></td>
			<td class="list-col-action">
				<form method="post" action="delete.php">
					<input type="hidden" name="table" value="mailbox">
					<input type="hidden" name="delete" value="{$item.username}">
					<input type="hidden" name="token" value="{$smarty.session.PFA_token|escape:"quotes"}">
					<button type="submit" class="pfa-action-btn pfa-btn-delete" title="{$PALANG.del}" aria-label="{$PALANG.del}" onclick="return confirm ('{$PALANG.confirm}{$PALANG.mailboxes}: {$RAW_tMailbox[$i].username|escape:'javascript'|escape:'html'}');">
						<svg class="pfa-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>
					</button>
				</form>
			</td>
		</tr>
	{/foreach}
	</tbody>
</table>
