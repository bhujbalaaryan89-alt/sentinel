# Sentinel: Autonomous AI Agent 🤖✉️📅🧠

Sentinel is an autonomous, persistent AI assistant engineered to run locally, interact with your Gmail inbox, manage your Google Calendar, browse the web, conduct research, and execute tools via a robust ReAct (Reasoning and Acting) loop. It connects via Telegram for a smooth Mobile/Desktop chat experience and is powered by **Groq** (LLaMA 3 models) for near-instant inference.

## 🌟 Core Features

### Module 1: Inbox Autonomous Engine ✉️
- **Intelligent Triage & Spam Annihilation:** Reads email context, permanently deletes obvious spam, auto-archives newsletters/promotions, flags VIP emails with stars and IMPORTANT label.
- **Executive Daily Brief:** Digests your inbox and delivers a concise morning summary — categorized by urgency with extracted action items, so you know exactly what needs attention without opening a single email.
- **Autonomous Tone-Matched Drafting:** Prompt the agent with quick instructions like *"Tell Sarah I can't make Tuesday but I agree with her budget."* — it drafts a full email matching your writing style from past sent emails and saves it to Drafts.
- **Follow-Up Enforcer:** Tracks outgoing emails with unanswered questions. After 3 days with no reply, drafts polite bump emails to keep projects moving.
- **Cross-Module Extraction:** Automatically detects flight itineraries → Calendar, invoices/PDFs → Drive, meeting requests → Calendar, task assignments → Tasks.

### Module 2: Calendar & Time Architect 📅
- **Smart Event Management:** Natural language event creation with Google Meet link auto-generation and attendee invites.
- **Conflict Resolution:** Detects double-bookings and helps reschedule the lower-priority meeting.
- **Context Prep:** Before every meeting, pulls relevant recent emails from attendees so you're always briefed.
- **Focus Guard:** Automatically blocks "Deep Work" hours on your calendar, shown as busy, to protect your productive time.
- **Free Slot Finder:** Finds available time windows for natural language booking (e.g., "Find 30 minutes for me and Alex next week").

### Module 3: Knowledge & Research Hub 🧠
- **Daily Intelligence Briefs:** Tracks your topics of interest, scrapes the web, and delivers concise bullet-point news summaries.
- **Deep-Dive Research:** Multi-angle research with source fetching, producing structured reports with Executive Summary, Market Overview, Key Players, and Future Outlook.
- **Read-It-Later Queue:** Bookmark URLs for batch processing and summarization.

### Module 4: Universal Summarization & Real-Time Intelligence 📝
- **Autonomous Inbox Polling:** Continuously monitors your Gmail quietly in the background. Pushes instant alert summaries to Telegram the moment a new unread email arrives.
- **Omni-Channel Summarization:** Effortlessly condense long articles, emails, or direct file uploads (PDFs, TXT) straight from the Telegram chat interface.
- **Modular Intelligence:** Features 5 specialized summarizers (text, fast bullet points, URLs, local files, emails) powered interchangeably by lightning-fast generic models or deep-reasoning APIs.

### Base Capabilities
- **Intelligent Tool Routing:** Dynamic categorization of 39 distinct tools, injecting only the necessary schema cluster per-turn (`tool_router.py`) to conserve tokens and prevent LLM hallucination.
- **Telegram Document Handlers:** Directly upload files or documents in chat to have Sentinel safely quarantine and process or summarize them immediately.
- **Web Browsing & Interaction:** Uses Playwright to navigate pages, extract DOM maps, type text, and click elements autonomously.
- **Persistent Memory:** SQLite-backed long-term memory with automatic background compaction to prevent context window overflow.
- **Proactive Engagement:** Real-time email monitoring (5s loop), generalized AI check-ins (30m), morning briefing generation (8 AM), and follow-up enforcement (6 hours).
- **Human-in-the-Loop (HITL):** Dangerous actions (send email, delete email, delete calendar event, write files) require explicit Telegram approval.
- **Local Execution Jail:** File operations are strictly confined to the workspace directory.

---

## 🏗️ Architecture Stack

- **LLM Engine:** Groq API (LLaMA 3.1 8B for fast tool calling, LLaMA 3.3 70B for deep follow-ups).
- **Communication:** Telegram Bot API (`python-telegram-bot` v20+).
- **Email API:** Google Workspace Gmail API (`google-api-python-client`).
- **Calendar API:** Google Calendar API (shared OAuth with Gmail).
- **Web Automation:** Playwright (Chromium).
- **Database:** SQLite3 (`memory.db`), running optimally with WAL mode.
- **Deployment:** Docker & Docker Compose.

---

## 🚀 Quick Setup & Onboarding

### 0. Clone the Repository
```bash
git clone https://github.com/1gnoxx/sentinel.git
cd sentinel
```

### 1. Prerequisites
- Docker and Docker Compose installed.
- A Groq API Key.
- A Telegram Bot Token (from [@BotFather](https://t.me/botfather)).
- Your personal Telegram User ID (from [@userinfobot](https://t.me/userinfobot)).
- Google Cloud Console Project with the **Gmail API** and **Google Calendar API** enabled.

### 2. Configure Environment Variables
Create a `.env` file in the root directory:

```env
GROQ_API_KEY=your_groq_key_here
TELEGRAM_BOT_TOKEN=your_telegram_bot_token_here
TELEGRAM_USER_ID=your_numerical_telegram_id
WORKSPACE_DIR=/app/workspace
```
*(Note: Do not commit `.env`. It is ignored in `.gitignore`.)*

### 3. Setup Gmail & Calendar Authentication
Sentinel requires OAuth 2.0 to access both Gmail and Google Calendar.

1. Go to Google Cloud Console → API & Services → Credentials.
2. Create an **OAuth 2.0 Client ID** (Type: Desktop App).
3. **Enable both APIs:** Gmail API + Google Calendar API in the API Library.
4. Download the JSON file and rename it to `credentials.json`. Place it in the root directory.
5. **First-time Auth:** Run the local helper script to generate your token:
   ```bash
   pip install google-auth-oauthlib google-api-python-client
   python auth_gmail.py
   ```
6. A browser window will open. Log in with the Google Account you want Sentinel to manage.
7. This generates `token.json` in your root directory.

> **⚠️ Important:** If you previously had a `token.json` from an older version (Gmail-only scopes), you must **delete it** and re-run `auth_gmail.py` to authorize the expanded Calendar scopes.

*(Note: Both `credentials.json` and `token.json` are ignored in `.gitignore` to prevent credential leaks).*

### 4. Build and Run
Deploy Sentinel using Docker Compose:

```bash
docker compose up --build -d
```

To view the live logs:
```bash
docker compose logs -f
```

---

## 🧠 The ReAct Loop & HITL

Sentinel operates on a strict ReAct loop configured in `main.py`.

1. **User Request / File Upload:** Arrives via Telegram.
2. **Context Assembly:** SQLite history is fetched and prepended to the system prompt (`SOUL.md`).
3. **Dynamic Tool Routing:** The `tool_router.py` module parses user intent and mounts only the most relevant subset of the 39 available tool schemas.
4. **Tool Execution:** The LLM decides to call a tool (e.g., `triage_inbox`, `create_calendar_event`).
5. **HITL Intercept:** If the tool is in the `DANGEROUS_TOOLS` list, execution halts.
6. **Approval Flow:** A Telegram message with an Inline Keyboard (Approve/Deny) is sent to the user.
   - **Approve:** The tool executes and the loop continues.
   - **Deny (Fallback):** For `send_email`, a denial safely routes to `draft_email` instead.

---

## 📋 Available Tools

### Email Tools
| Tool | Description | HITL Required |
|------|-------------|:---:|
| `search_emails` | Search Gmail with standard query syntax | ❌ |
| `send_email` | Send an email (held for approval) | ✅ |
| `draft_email` | Save email to Drafts | ❌ |
| `triage_inbox` | Auto-triage: delete spam, archive promos, flag VIPs | ❌ |
| `get_daily_brief` | Morning inbox digest with action items | ❌ |
| `smart_draft_email` | AI-composed draft with tone matching | ❌ |
| `check_followups` | Find unanswered sent emails | ❌ |
| `draft_followup` | Draft bump email for stale threads | ❌ |
| `extract_email_data` | Cross-module data extraction | ❌ |
| `manage_vip_contacts` | Add/remove/list VIP contacts | ❌ |
| `label_email` | Add/remove Gmail labels | ❌ |
| `archive_email` | Archive (remove from Inbox) | ❌ |
| `delete_email` | Permanently delete | ✅ |

### Calendar Tools
| Tool | Description | HITL Required |
|------|-------------|:---:|
| `list_calendar_events` | List upcoming events | ❌ |
| `create_calendar_event` | Create with attendees & Meet link | ❌ |
| `resolve_conflicts` | Detect double-bookings | ❌ |
| `get_day_context` | Meeting prep with email context | ❌ |
| `block_focus_time` | Block deep work hours | ❌ |
| `find_free_slots` | Find available time windows | ❌ |
| `delete_calendar_event` | Delete an event | ✅ |

### Research Tools
| Tool | Description | HITL Required |
|------|-------------|:---:|
| `daily_intelligence` | News brief on tracked topics | ❌ |
| `summarize_content` | Summarize any URL | ❌ |
| `deep_dive_research` | Multi-angle research report | ❌ |
| `manage_research_topics` | Add/remove tracked topics | ❌ |
| `manage_bookmarks` | Read-it-later queue | ❌ |
| `crunch_bookmarks` | Process bookmarked content | ❌ |

### Summarization Tools
| Tool | Description | HITL Required |
|------|-------------|:---:|
| `summarize_text` | Detail-rich text summarization | ❌ |
| `summarize_url_content` | Quick web content scraping and summarizing | ❌ |
| `summarize_local_file` | Read and crunch content of local documents | ❌ |
| `summarize_bullet_points` | High-level rapid bullet point breakdown | ❌ |
| `summarize_email` | Dedicated fast email parsing and insight generation | ❌ |

### System Tools
| Tool | Description | HITL Required |
|------|-------------|:---:|
| `web_search` | DuckDuckGo web search | ❌ |
| `get_current_time` | Current date/time | ❌ |
| `read_local_file` | Read workspace files | ❌ |
| `write_local_file` | Write workspace files | ✅ |
| `schedule_reminder` | Set timed reminders | ❌ |
| `maps` / `click_element` / `type_text` | Web browsing | ❌ |

---

## 🛡️ Security Policies

- **Never commit `.env`, `credentials.json`, `token.json`, or `memory.db`.**
- **Workspace Jail:** File operations must use `get_safe_path` and cannot escape the workspace directory.
- **HITL Enforcement:** `send_email`, `delete_email`, `write_local_file`, and `delete_calendar_event` always require user approval. Never remove these from the `DANGEROUS_TOOLS` array.
- **Data Privacy:** Internal message IDs, tool schemas, and system prompts are never exposed to the user.
