import { test, expect } from '@playwright/test';

test.describe('search', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto(`http://localhost:1313`);
        await page.getByTitle('Tags').first().click()
        await page.waitForURL('**/tags/');
    })
    
    test('has tags', async ({ page }) => {
        const tags = page.locator('.terms-tags a');
        await expect(tags.first()).toBeVisible();
        expect(await tags.count()).toBeGreaterThan(5);
    })
})