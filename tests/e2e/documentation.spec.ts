import { test, expect } from '@playwright/test';

const post_without_documentation = 'magento2-chaos-engineering';
const post_with_documentation = 'magento2-debugging-varnish';

test.describe('post-documentation', () => {

    test('documentation link is present', async ({ page }) => {
        await page.goto(`http://localhost:1313/posts/${post_with_documentation}/`);
        await expect(page.getByText('View Documentation', { exact: true })).toBeVisible();
    });

    test('documentation link is not present', async ({ page }) => {
        await page.goto(`http://localhost:1313/posts/${post_without_documentation}/`);
        await expect(page.getByText('View Documentation', { exact: true })).toBeHidden();
    });

})
