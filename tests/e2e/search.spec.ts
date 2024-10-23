import { test, expect } from '@playwright/test';

test.describe('search', () => {
    test.beforeEach(async ({ page }, testInfo) => {
        // Navigation takes place in the actual task
        if (testInfo.title === 'search via query parameter') { return; }

        await page.goto(`http://localhost:1313`);
        await page.getByTitle('Search (Alt + /)').first().click()
        await page.waitForURL('**/search/');
    })
    
    test('has search input', async ({ page }) => {
        await expect(page.getByLabel('search', { exact: true })).toBeVisible();
    })

    test('search input function', async ({ page }) => {
        const search = page.getByLabel('search', { exact: true });
        await search.pressSequentially('magento')

        const resultLinks = page.locator('.post-entry a')
        expect(await resultLinks.count()).toBeGreaterThan(0)

        await resultLinks.first().click()
        await page.waitForURL('**/posts/**')
        expect(page.url()).toContain('/posts/')
    })

    test('search via query parameter', async ({ page }) => {
        const query = 'varnish';
        await page.goto(`http://localhost:1313/search/?q=${query}`);
        await expect(page.getByLabel('search', { exact: true })).toHaveValue(query)
        await expect(page.locator('.post-entry a').first()).toBeInViewport()
    })

  


})