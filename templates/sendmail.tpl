<div class="mf-page-header">
    <div class="mf-page-header-left">
        <p class="mf-eyebrow">Mensagens</p>
        <h1 class="mf-page-title">{$PALANG.pSendmail_welcome}</h1>
    </div>
    <div class="mf-page-header-actions">
        <button class="mf-btn-primary" type="submit" name="submit" form="pfa-sendmail-form">
            <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
            {$PALANG.pSendmail_button}
        </button>
    </div>
</div>

<div class="mf-content">
    <div class="mf-form-wrap">
        <form id="pfa-sendmail-form" name="mailbox" method="post" action="" class="form-horizontal">
            <div id="edit_form" class="mf-form-sheet">
                <div class="mf-form-sheet-body enable-asterisk">
                    <input class="flat" type="hidden" name="token" value="{$smarty.session.PFA_token|escape:"url"}"/>
                    <div class="form-group">
                        <label class="col-md-3 col-sm-4 control-label">{$PALANG.from}:</label>
                        <div class="col-md-9 col-sm-8"><p class="form-control-static">{$smtp_from_email}</p></div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 col-sm-4 control-label" for="fTo">{$PALANG.pSendmail_to}:</label>
                        <div class="col-md-9 col-sm-8"><input class="form-control" type="text" name="fTo" id="fTo"/></div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 col-sm-4 control-label" for="fSubject">{$PALANG.subject}:</label>
                        <div class="col-md-9 col-sm-8"><input class="form-control" type="text" name="fSubject" id="fSubject"
                                                              value="{$PALANG.pSendmail_subject_text}"/></div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 col-sm-4 control-label" for="fBody">{$PALANG.pSendmail_body}:</label>
                        <div class="col-md-9 col-sm-8"><textarea class="form-control" rows="10" cols="60" name="fBody"
                                                                 id="fBody">{$CONF.welcome_text}</textarea></div>
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
