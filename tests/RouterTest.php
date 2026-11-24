<?php

use PHPUnit\Framework\TestCase;

class RouterTest extends TestCase
{
    public function testResolveStaticAdminRoutes(): void
    {
        $r = Router::resolve('/login');
        $this->assertSame(['script' => 'login.php', 'user_context' => false, 'params' => []], $r);

        $r2 = Router::resolve('/broadcast');
        $this->assertSame(['script' => 'broadcast-message.php', 'user_context' => false, 'params' => []], $r2);

        $r3 = Router::resolve('/virtual');
        $this->assertSame(['script' => 'list-virtual.php', 'user_context' => false, 'params' => []], $r3);
    }

    public function testResolveParameterizedTableRoutes(): void
    {
        $r = Router::resolve('/edit/mailbox');
        $this->assertSame(['script' => 'edit.php', 'user_context' => false, 'params' => ['table' => 'mailbox']], $r);

        $r2 = Router::resolve('/list/domain');
        $this->assertSame(['script' => 'list.php', 'user_context' => false, 'params' => ['table' => 'domain']], $r2);

        $r3 = Router::resolve('/delete/alias');
        $this->assertSame(['script' => 'delete.php', 'user_context' => false, 'params' => ['table' => 'alias']], $r3);
    }

    public function testResolveUserRoutes(): void
    {
        $r = Router::resolve('/users/login');
        $this->assertSame(['script' => 'login.php', 'user_context' => true, 'params' => []], $r);

        $r2 = Router::resolve('/users/password-recover');
        $this->assertSame(['script' => 'password-recover.php', 'user_context' => true, 'params' => []], $r2);
    }

    public function testResolveSubdirectoryBasePath(): void
    {
        $r = Router::resolve('/postfixadmin/edit/domain', '/postfixadmin');
        $this->assertSame(['script' => 'edit.php', 'user_context' => false, 'params' => ['table' => 'domain']], $r);

        $this->assertNull(Router::resolve('/other/edit/domain', '/postfixadmin'));
    }

    public function testRejectsTraversalAndInvalidRoutes(): void
    {
        $this->assertNull(Router::resolve('/../config.local.php'));
        $this->assertNull(Router::resolve('/edit/Mailbox123'));
        $this->assertNull(Router::resolve('/nonexistent'));
        $this->assertNull(Router::resolve("/login\0.php"));
        $this->assertNull(Router::resolve('/upgrade'));
    }

    public function testLegacyUrlConversion(): void
    {
        $this->assertSame('/edit/mailbox?domain=example.com', Router::url('edit.php?table=mailbox&domain=example.com'));
        $this->assertSame('/list/domain', Router::url('list.php?table=domain'));
        $this->assertSame('/virtual?domain=example.com', Router::url('list-virtual.php?domain=example.com'));
        $this->assertSame('/broadcast', Router::url('broadcast-message.php'));
        $this->assertSame('/users/main', Router::url('main.php', true));
        $this->assertSame('/login', Router::url('../login.php', true));
        $this->assertSame('/pfa/edit/domain', Router::url('edit.php?table=domain', false, '/pfa'));
        $this->assertSame('https://example.com/a.php', Router::url('https://example.com/a.php'));
        $this->assertSame('//evil.com/login.php', Router::url('//evil.com/login.php'));
    }

    public function testRewriteHtmlRewritesLinksFormsAndAssets(): void
    {
        $html = '<a href="edit.php?table=mailbox&amp;domain=a.com">Add</a>'
            . '<form action="list-virtual.php" method="post"></form>'
            . '<img src="images/postbox.png" />'
            . '<textarea name="message"><a href="login.php">Keep verbatim</a></textarea>'
            . '<script>var x = \'href="login.php"\';</script>';

        $out = Router::rewriteHtml($html, false);

        $this->assertStringContainsString('href="/edit/mailbox?domain=a.com"', $out);
        $this->assertStringContainsString('action="/virtual"', $out);
        $this->assertStringContainsString('src="/images/postbox.png"', $out);
        $this->assertStringContainsString('<textarea name="message"><a href="login.php">Keep verbatim</a></textarea>', $out);
        $this->assertStringContainsString('<script>var x = \'href="login.php"\';</script>', $out);
    }

    public function testExtractBaseUrlPathIgnoresCommentedLines(): void
    {
        $commented = "<?php\n// \$CONF['base_url_path'] = '/postfixadmin';\n# \$CONF['base_url_path'] = '/other';\n";
        $this->assertSame('', Router::extractBaseUrlPathFromSnippet($commented));

        $active = "<?php\n// \$CONF['base_url_path'] = '/wrong';\n\$CONF['base_url_path'] = '/pfa/';\n";
        $this->assertSame('/pfa', Router::extractBaseUrlPathFromSnippet($active));
    }
}
