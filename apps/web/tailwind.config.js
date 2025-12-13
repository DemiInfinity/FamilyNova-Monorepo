/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        // Kids App Colors
        'primary-blue': '#4A90E2',
        'primary-green': '#50C878',
        'primary-orange': '#FF6B35',
        'primary-purple': '#9B59B6',
        // Parent App Colors
        'navy': '#2C3E50',
        'teal': '#16A085',
        'indigo': '#5B6C7D',
        'gold': '#F39C12',
        // Status Colors
        'success': '#27AE60',
        'warning': '#F39C12',
        'error': '#E74C3C',
        'info': '#3498DB',
      },
    },
  },
  plugins: [],
}

