import { test, expect } from '@playwright/test';

test.describe('post', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto(`http://localhost:1313`);
        await page.getByLabel('post link to').first().click()
        await page.waitForURL('**/posts/**');
    })

    test('has share buttons', async ({ page }) => {
        await expect(page.locator('[href*="reddit.com/submit"]')).toBeVisible();
        await expect(page.locator('[href*="linkedin.com/shareArticle"]')).toBeVisible();
        await expect(page.locator('[href*="x.com/intent/tweet/"]')).toBeVisible();
        await expect(page.locator('[href*="facebook.com/sharer"]')).toBeVisible();
    })

    test('has post tags', async ({ page }) => {
        await expect(page.locator('.post-tags a').first()).toBeVisible();
    })

    test('has post navigation', async ({ page }) => {
        await expect(page.locator('.paginav .next')).toBeVisible();
    })

    test('has edit cta block', async ({ page }) => {
        await expect(page.getByText('open an issue / PR on the Github Repo')).toBeVisible();
    })

    test('has suggest changes link', async ({ page }) => {
        await expect(page.getByText('Suggest Changes', { exact: true })).toBeVisible();
    })


})
