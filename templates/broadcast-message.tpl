<div class="mf-page-header">
    <div class="mf-page-header-left">
        <p class="mf-eyebrow">Mensagens</p>
        <h1 class="mf-page-title">{$PALANG.pBroadcast_title}</h1>
    </div>
    <div class="mf-page-header-actions">
        <button class="mf-btn-primary" type="submit" name="submit" form="pfa-broadcast-form">
            <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
            {$PALANG.pSendmail_button}
        </button>
    </div>
</div>

<div class="mf-content">
    <div class="mf-form-wrap">
        <form id="pfa-broadcast-form" name="broadcast-message" method="post" action="" class="form-horizontal">
            <div id="edit_form" class="mf-form-sheet">
                <div class="mf-form-sheet-body">
                    <input class="flat" type="hidden" name="token" value="{$smarty.session.PFA_token|escape:"url"}" />
                    <div class="form-group">
                        <label class="col-md-3 col-sm-4 control-label">{$PALANG.from}:</label>
                        <div class="col-md-9 col-sm-8"><p class="form-control-static">{$smtp_from_email}</p></div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 col-sm-4 control-label" for="name">{$PALANG.pBroadcast_name}:</label>
                        <div class="col-md-9 col-sm-8"><input class="form-control" type="text" name="name" id="name" /></div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 col-sm-4 control-label" for="subject">{$PALANG.subject}:</label>
                        <div class="col-md-9 col-sm-8"><input class="form-control" type="text" name="subject" id="subject" /></div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 col-sm-4 control-label" for="message">{$PALANG.message}:</label>
                        <div class="col-md-9 col-sm-8"><textarea class="form-control" rows="8" cols="40" name="message" id="message"></textarea></div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 col-sm-4 control-label"></label>
                        <div class="col-md-9 col-sm-8">
                            <div class="checkbox"><label><input type="checkbox" value="1" name="mailboxes_only"/> {$PALANG.broadcast_mailboxes_only}</label></div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 col-sm-4 control-label" for="domains">{$PALANG.broadcast_to_domains}</label>
                        <div class="col-md-9 col-sm-8">
                            <select multiple="multiple" name="domains[]" id="domains" class="form-control" size="8">
                                {html_options output=$allowed_domains values=$allowed_domains selected=$allowed_domains}
                            </select>
                        </div>
                    </div>
                </div>
                <div class="mf-form-sheet-footer">
                    <button class="mf-btn-primary" type="submit" name="submit">
                        <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
                        {$PALANG.pSendmail_button}
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>
