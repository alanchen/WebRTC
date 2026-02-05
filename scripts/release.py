import os
import json
import requests
from datetime import datetime, timedelta
from dataclasses import dataclass
import telegram

GITHUB_TOKEN=os.environ.get("GITHUB_TOKEN")
TELEGRAM_TOKEN=os.environ.get("TELEGRAM_TOKEN")
TELEGRAM_CHAT_ID=os.environ.get("TELEGRAM_CHAT_ID")
REPO=os.environ.get("GITHUB_REPOSITORY", "alanchen/WebRTC")

@dataclass
class NextReleaseResult:
    version: int
    releaseDate: datetime
    branch: str

@dataclass
class BuildMetadata:
    filename: str
    checksum: str
    commit: str
    branch: str

def getNextRelease():
    # 取得目前 repo 的最新 release 版本
    releases = requests.get(f"https://api.github.com/repos/{REPO}/releases", headers={'Authorization': f"token {GITHUB_TOKEN}"}).json()
    print(releases)
    latestReleaseVersion = int(releases[0]["tag_name"].split(".")[0])
    print(f"Latest release in our repo: version {latestReleaseVersion}")

    # 從 current+1 開始往上找，找到最新的已穩定版本
    latestStableVersion = None
    latestStableDate = None
    latestStableBranch = None

    version = latestReleaseVersion + 1
    while True:
        try:
            schedule = requests.get(f"https://chromiumdash.appspot.com/fetch_milestone_schedule?mstone={version}").json()
            if not schedule.get("mstones"):
                break
            stableDate = datetime.fromisoformat(schedule["mstones"][0]["stable_date"])
            if datetime.today() >= (stableDate + timedelta(days=1)):
                # 這個版本已穩定，記錄下來，繼續往上找
                milestoneInfo = requests.get(f"https://chromiumdash.appspot.com/fetch_milestones?mstone={version}").json()
                latestStableVersion = version
                latestStableDate = stableDate
                latestStableBranch = "branch-heads/" + milestoneInfo[0]["webrtc_branch"]
                print(f"  Found stable version: M{version}, date: {stableDate}")
                version += 1
            else:
                break
        except:
            break

    if latestStableVersion is None:
        return None

    print(f"Latest stable version to build: M{latestStableVersion}")
    return NextReleaseResult(version = latestStableVersion, releaseDate = latestStableDate, branch = latestStableBranch)

def buildWebRTC(branch):
    os.environ["BUILD_VP9"] = "true"
    os.environ["BRANCH"] = branch
    os.environ["IOS"] = "true"
    os.environ["MACOS"] = "false"
    os.environ["MAC_CATALYST"] = "false"

    return os.system('sh scripts/build.sh') == 0

def getBuildMetadata(outputDir):
    with open(f"{outputDir}/metadata.json", 'r') as f:
        jsonData = json.loads(f.read())
        return BuildMetadata(filename = jsonData['file'], checksum = jsonData['checksum'], commit = jsonData['commit'], branch = jsonData['branch'])

def createReleaseDraft(release, buildMetadata):
    body = f"Release notes: https://webrtc.googlesource.com/src.git/+log/refs/{buildMetadata.branch}/\n"
    body += f"WebRTC Branch: [{buildMetadata.branch}](https://chromium.googlesource.com/external/webrtc/+log/{buildMetadata.branch})\n"
    body += f"WebRTC Commit: `{buildMetadata.commit}`\n"
    body += f"SHA 256 checksum: `{buildMetadata.checksum}`"

    fields = { 
        'name': f'M{release.version}',
        'tag_name': f'{release.version}.0.0',
        'draft': True,
        'body': body
    }
    headers = {'accept': 'application/vnd.github.v3+json', 'Authorization': f'token {GITHUB_TOKEN}'}
    return requests.post(f"https://api.github.com/repos/{REPO}/releases", json = fields, headers = headers).json()

def uploadReleaseAsset(url, assetLocalPath, assetName):
    url = url.replace(u'{?name,label}','')
    fileToUpload = open(assetLocalPath, 'rb')  
    size = os.stat(assetLocalPath).st_size
    params = {'name': assetName}
    headers = {'Authorization': f'token {GITHUB_TOKEN}', 'Content-Length': str(size), 'Content-Type': 'Application/zip'}
    response = requests.post(url, params = params, data = fileToUpload, headers = headers)
    success = response.status_code == requests.codes.created
    if not success:
        print(response)
    return success

def createPullRequest(release, head):
    headers = {'accept': 'application/vnd.github.v3+json', 'Authorization': f'token {GITHUB_TOKEN}'}
    body = { 
        'title': f'Release M{release.version}',
        'head': head,
        'base': 'latest',
        'body': 'Created by an automated sotfware 🤖'
    }
    response = requests.post(f"https://api.github.com/repos/{REPO}/pulls", json = body, headers = headers)
    success = response.status_code == requests.codes.created
    if not success:
        print(response)
    return success

if __name__ == "__main__":
    if not GITHUB_TOKEN:
        print("❌ GITHUB_TOKEN environment variable is not provided")
        os._exit(os.EX_SOFTWARE)

    # Get next release details
    print("➡️ Fetching latest stable release...")
    nextRelease = getNextRelease()

    if nextRelease is None:
        print("ℹ️  No new stable version available. Skipping build")
        os._exit(os.EX_OK)

    print(f"✅ {nextRelease}\n")
    print(f"✅ Will build M{nextRelease.version}")

    # Build WebRTC Frameworks
    print("➡️ Building WebRTC Library...")
    buildSuccess = buildWebRTC(nextRelease.branch)
    if not buildSuccess:
        print("❌ WebRTC Build Failed")
        os._exit(os.EX_SOFTWARE)
        
    print("✅ WebRTC build successful\n")

    # Get metadata build file - it has all the information needed about the build
    outputDir="src/out"
    buildMetadata = getBuildMetadata(outputDir)
    print(buildMetadata)

    # Create new release draft
    print("➡️ Creating new release draft...")
    githubReleaseDraft = createReleaseDraft(nextRelease ,buildMetadata)

    # Upload asset to github
    print("➡️ Uploading asset to github...")
    assetName = f"WebRTC-M{nextRelease.version}.xcframework.zip"
    assetPath = os.path.join(outputDir, buildMetadata.filename)
    uploadURL = githubReleaseDraft['upload_url']
    uploadResult = uploadReleaseAsset(uploadURL, assetPath, assetName)

    if not uploadResult:
        print("❌ Failed uploading asset to github")
        os._exit(os.EX_SOFTWARE)

    print(f"✅ Successfully created new draft release in github: {githubReleaseDraft['url']}")

    # Create new branch with code changes
    print("➡️ Creating local branch...")
    releaseBranch = f'release-M{nextRelease.version}'
    os.system(f'git checkout -b {releaseBranch}')

    # Change code
    print("➡️ Applying code changes...")
    os.system(f"sed -i '' -E 's/[0-9]+.0.0\/WebRTC-M[0-9]+/{nextRelease.version}.0.0\/WebRTC-M{nextRelease.version}/g' Package.swift WebRTC-lib.podspec")
    os.system(f"sed -i '' -E 's/checksum: \"[0-9a-f]+\"/checksum: \"{buildMetadata.checksum}\"/g' Package.swift WebRTC-lib.podspec ")
    os.system(f"sed -i '' -E 's/.upToNextMajor\\(\"[0-9]+.0.0/.upToNextMajor\\(\"{nextRelease.version}.0.0/g' README.md")
    os.system(f"sed -i '' -E 's/spec.version      = \"[0-9]+.0.0\"/spec.version      = \"{nextRelease.version}.0.0\"/g' WebRTC-lib.podspec")
    cartageFile = open("WebRTC.json", 'r')

    cartageJSON = json.loads(cartageFile.read())
    cartageJSON[f'{nextRelease.version}.0.0'] = f'https://github.com/{REPO}/releases/download/{nextRelease.version}.0.0/WebRTC-M{nextRelease.version}.xcframework.zip'
    cartageFile.close()
    cartageJSONWrite = open("WebRTC.json", 'w')
    cartageJSONWrite.write(json.dumps(cartageJSON, indent=4, sort_keys=True))
    cartageJSONWrite.close()


    # Commit and push
    print("➡️ Commiting and pushing code to remote...")
    os.system(f'git add Package.swift WebRTC-lib.podspec README.md WebRTC.json')
    os.system(f'git commit -m "Updated files for release M{nextRelease.version}"')
    os.system(f'git push origin {releaseBranch}')

    # Create PR
    print("➡️ Creating pull request...")
    prResult = createPullRequest(nextRelease, releaseBranch)
    if not prResult:
        print("❌ Failed creating pull request in github")
        os._exit(os.EX_SOFTWARE)

    # Notify about the new release via Telegram bot
    if TELEGRAM_TOKEN and TELEGRAM_CHAT_ID:
        print("➡️ Sending Telegram notification...")
        bot = telegram.Bot(token=TELEGRAM_TOKEN)
        message = f"New WebRTC Release M{nextRelease.version} is now available.\nCheck the PR here: https://github.com/{REPO}/pulls"
        bot.send_message(chat_id=TELEGRAM_CHAT_ID, text=message)

    print(f"✅ Done")
