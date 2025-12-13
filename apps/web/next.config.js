/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  env: {
    API_URL: process.env.API_URL || 'http://192.168.50.50:3000/api',
  },
}

module.exports = nextConfig
