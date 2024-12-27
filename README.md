# Tooltime 🔧

*Does everybody know what time it is? TOOL TIME!*

A power tool for tracking your tech stack's lifecycle information. More power! 🤖 

[![Tool Time](https://img.shields.io/badge/More%20Power-Arr%20Arr%20Arr-blue)](https://github.com/loftwah/tooltime)

## What's Tooltime? 

Like Tim "The Tool Man" Taylor upgrading his hot rod, this tool helps you keep your tech stack tuned up and running smoothly. It tracks versions, lifecycle information, and sends you monthly updates about what needs attention.

> "I rewired the GitHub API call. Now it has **MORE POWER!** Arr arr arr!" 🔧

## Features

- 🛠️ Tracks versions and lifecycle information for your tech stack
- 🔥 Monitors trending GitHub repositories
- 📬 Sends monthly email updates (without any power tool accidents)
- ⚠️ Warns about upcoming EOL dates (like Al warning Tim about safety)
- 🚀 Shows latest releases and LTS versions

## Setup

### Local Workshop Setup

1. Clone your new power tool:
```bash
git clone https://github.com/loftwah/tooltime
cd tooltime
```

2. Install the tool attachments (dependencies):
```bash
gem install nokogiri
gem install dotenv
```

3. Set up your workshop environment (`.env`):
```bash
RESEND_API_KEY=re_your_key_here
RECIPIENT_EMAIL=your@email.com
GITHUB_TOKEN=your_github_token  # Optional for local testing
```

### Automated Workshop (GitHub Actions)

1. Add these secrets to your GitHub repository:
   - `RESEND_API_KEY`: Your Resend API key (from https://resend.com)
   - `RECIPIENT_EMAIL`: Email address for updates

2. The automated workshop runs monthly, or you can trigger it manually (like Tim hitting the turbo button).

## Usage

### Testing in Your Workshop

Basic power setting:
```bash
ruby tooltime.rb
```

MORE POWER (HTML output):
```bash
ruby tooltime.rb --format html
```

Maximum power (preview email):
```bash
ruby tooltime.rb --format html && ruby send_update.rb
```

### Tool Settings

- `--format html`: Generate HTML output (the deluxe model)
- `--output filename.html`: Custom output file

## Workshop Layout

```
.
├── .github/
│   └── workflows/           # The automated workshop
│       └── tech-update.yml
├── config/
│   └── tech_stack.rb       # Your tool collection
├── lib/                    # The power components
│   ├── data_fetcher.rb
│   ├── display.rb
│   └── html_formatter.rb
├── .env                    # Your secret workshop upgrades
├── .gitignore
├── tooltime.rb            # The main power tool
└── send_update.rb         # The notification system
```

## Email Configuration

1. Sign up at [Resend](https://resend.com) (no power tools required)
2. Verify your domain/email
3. Get your API key (Settings → API Keys → Create API Key)
4. Add it to your repository secrets

## Workshop Safety (Environment Setup)

Create a `.env` file:
```bash
# Required for notifications
RESEND_API_KEY=re_your_key_here
RECIPIENT_EMAIL=your@email.com

# Optional for more power
GITHUB_TOKEN=your_github_token
```

Don't forget your safety gear (`.gitignore`):
```
.env
tech_update.html
```

## Troubleshooting

1. **Rate Limiting**: Even Tim Taylor couldn't exceed GitHub's rate limits. Use a token for more power.
2. **Email Issues**: Make sure your email is verified (don't forget to plug it in).
3. **Missing Data**: Some tools might be hiding in the workshop. Check the APIs.

## Contributing

I don't think so, Tim! (Just kidding, contributions are welcome! Please submit a Pull Request.)

## License

MIT License - Free to modify and upgrade, just like Tim's tools!

---
*Remember: Always wear safety glasses when running GitHub Actions!* 👓

Built with MORE POWER by [Loftwah](https://github.com/loftwah) 🔧