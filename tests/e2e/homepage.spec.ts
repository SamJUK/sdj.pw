import { test, expect } from '@playwright/test';

test.describe('homepage', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto(`http://localhost:1313`);
    })

    test('has social links', async ({ page }) => {
        await expect(page.getByRole('link', { name: 'Stackoverflow' })).toBeVisible()
        await expect(page.getByRole('link', { name: 'Github' })).toBeVisible()
        await expect(page.getByRole('link', { name: 'Linkedin' })).toBeVisible()
        await expect(page.getByRole('link', { name: 'RSS' })).toBeVisible()
    })

    test('has full post list', async ({ page }) => {
        // 10 posts + the intro text
        await expect(page.getByRole('article')).toHaveCount(11);
    })
    
    test('next page pagination', async ({ page }) => {
        await expect(page.locator('.pagination .next')).toBeVisible();
        await page.locator('.pagination .next').click()
        await expect(page).toHaveURL('http://localhost:1313/page/2/')
    })

})