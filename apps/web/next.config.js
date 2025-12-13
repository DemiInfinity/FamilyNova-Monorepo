/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  env: {
    API_URL: process.env.API_URL || 'https://family-nova-monorepo.vercel.app/api',
  },
}

module.exports = nextConfig
