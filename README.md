# lua-2-github

A simple **Luau script** to publish updates directly to GitHub.

---

## Getting Your GitHub Token

1. Go to [GitHub Personal Access Tokens](https://github.com/settings/tokens).  
2. Click **Generate new token → Generate new token (classic)**.  
3. Give your token a **name** (anything works).  
4. Under **Scopes**, enable:  
   - `repo` (allows read/write access to your repositories)  
5. Scroll down and click **Generate token**.  
6. **Copy and save your token**

---

## Setup

1. Open the Luau script.  
2. Find this line:  

   ```lua
   local TOKEN = "ghpTOKENHERE"
   ```
Replace "ghpTOKENHERE" with your actual GitHub token.

Notes
Don't share your token with anyone.

Make sure you have permissions on the repository you want to update.

Make sure your paths are updated to the repo you want to update.
