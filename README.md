# Tool Time End-of-Life Reporter

> "If you didn’t mark your software’s end-of-life date with more power, did it even happen?" – Tim the Toolman

Welcome to the **Tool Time End-of-Life Reporter**, a simple Ruby script for fetching and emailing EOL data. This script helps you track the important tech tools in your belt. Think of it like the _Binford 6100_ of software version awareness – **More data! More power!**

## Features

1. **Improved HTML Layout**

   - Your EOL report comes out looking _magically enhanced_, like adding a supercharger to your rundown pickup.
   - Each product’s versions, EOL status, and whether it’s an LTS (Long-Term Support) release is cleanly presented in its own table.

2. **Dry-Run Mode**

   - If `DRY_RUN='true'`, the script prints the HTML to the console but reminds you that it’s a dry-run.
   - Great for the days you want to _“opt out”_ of emailing your beloved teammates.

3. **Simple to Deploy**
   - Just load the environment variables, install dependencies with `bundle install`, and run `ruby main.rb`.
   - Even Al Borland couldn’t find fault with how easy it is!

## Getting Started

1. **Clone the Repo**

   ```bash
   git clone https://github.com/loftwah/tooltime.git
   ```

2. **Install Dependencies**

   ```bash
   bundle install
   ```

3. **Create your `.env`**

   ```bash
   cp .env.example .env
   # Fill in your details like SENDER_EMAIL, RECIPIENT_EMAIL, etc.
   ```

4. **Run the Script**

   ```bash
   ruby main.rb
   ```

   - By default, it’ll send the report if valid credentials are found.

5. **Dry-Run**

   - **Dry-Run**: `DRY_RUN='true' ruby main.rb`

## Environment Variables

| Variable          | Description                                | Required | Example                |
| ----------------- | ------------------------------------------ | -------- | ---------------------- |
| `RECIPIENT_EMAIL` | The email of the lucky EOL report receiver | Yes      | `someone@example.com`  |
| `SENDER_EMAIL`    | The email address used to send the report  | Yes      | `reporter@example.com` |
| `RESEND_API_KEY`  | Your Resend.com API key                    | Yes      | `abcd1234efgh5678`     |
| `DRY_RUN`         | If `true`, prints HTML to console only     | No       | `true`                 |

## Customising the Script

_It’s like adding a new speed dial to your hot rod – easy-peasy._

- **Tracked Techs**: Update the `TRACKED_TECHS` array in the script.
- **Styling**: Modify the `<style>` section within the `generate_html_report` method.

---

> _Remember_, folks: software may come and go, but with the **Tool Time End-of-Life Reporter**, you’ll always know when to let out that final Tim Allen grunt. So strap on your tool belt and keep those versions updated—**“More power!”**
