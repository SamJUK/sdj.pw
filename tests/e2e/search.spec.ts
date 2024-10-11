import { test, expect } from '@playwright/test';

test.describe('search', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto(`http://localhost:1313`);
        await page.getByTitle('Search').first().click()
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

  


})