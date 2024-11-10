#!/bin/bash

# 환경 변수 설정
export WORK="/root/walrus-testnet-bot"
export NVM_DIR="$HOME/.nvm"

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # 색상 초기화

echo -e "${GREEN}walrus 봇을 설치합니다.${NC}"
echo -e "${GREEN}스크립트작성자: https://t.me/kjkresearch${NC}"
echo -e "${GREEN}출처:https://github.com/Widiskel/walrus-testnet-bot${NC}"

echo -e "${GREEN}설치 옵션을 선택하세요:${NC}"
echo -e "${YELLOW}1. walrus 봇 새로 설치${NC}"
echo -e "${YELLOW}2. 재실행하기${NC}"
read -p "선택: " choice

case $choice in
  1)
    echo -e "${GREEN}walrus 봇을 새로 설치합니다.${NC}"

    # 사전 필수 패키지 설치
    echo -e "${YELLOW}시스템 업데이트 및 필수 패키지 설치 중...${NC}"
    sudo apt update
    sudo apt install -y git

    echo -e "${YELLOW}작업 공간 준비 중...${NC}"
    if [ -d "$WORK" ]; then
        echo -e "${YELLOW}기존 작업 공간 삭제 중...${NC}"
        rm -rf "$WORK"
    fi

    # GitHub에서 코드 복사
    echo -e "${YELLOW}GitHub에서 코드 복사 중...${NC}"
    git clone https://github.com/Widiskel/walrus-testnet-bot.git
    cd "$WORK"

    # Node.js LTS 버전 설치 및 사용
    echo -e "${YELLOW}Node.js LTS 버전을 설치하고 설정 중...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # nvm을 로드합니다
    nvm install --lts
    nvm use --lts
    npm install
    npm run setup

    echo -e "${YELLOW}해당사이트로 이동하여 월렛을 연결해주세요: https://stake.walrus.site/ ${NC}"
    echo -e "${GREEN}해당사이트에서 Faucet을 받아주세요: https://discord.com/invite/sui${NC}"
    echo -e "${GREEN}스테이킹을 진행해주세요.${NC}"
    read -p "위 작업이 끝나면 엔터를 쳐주세요 : "

    # 프록시파일 생성
    echo -e "${YELLOW}프록시 정보를 입력하세요. 입력형식: http://user:pass@ip:port${NC}"
    echo -e "${YELLOW}여러 개의 프록시는 줄바꿈으로 구분하세요.${NC}"
    echo -e "${YELLOW}입력을 마치려면 엔터를 두 번 누르세요.${NC}"

    {
        echo "export const proxyList = ["  # 파일 시작
        while IFS= read -r line; do
            [[ -z "$line" ]] && break
            # 입력된 프록시 정보를 그대로 사용
            echo "  \"$line\","
        done
        echo "];"  # 배열 끝
    } > "$WORK/config/proxiy_list.js"

    # config파일 생성
    echo -e "${YELLOW}SWAPCOUNT 값을 입력하세요. 기본값은 10입니다.${NC}"
    echo -e "${YELLOW}매 스왑ㅁ마다 0.1~0.5의 sui가 필요합니다.${NC}"
    read -p "SWAPCOUNT 입력 (기본값: 10): " swapcount

    # 기본값 설정
    swapcount=${swapcount:-10}  # 사용자가 입력하지 않으면 기본값 10 사용

    # config.js 파일 생성
    {
        echo "export class Config {"
        echo "  static TXAMOUNTMIN = 0.1; //TX AMOUNT MIN"
        echo "  static TXAMOUNTMAX = 0.5; //TX AMOUNT MAX"
        echo "  static SWAPCOUNT = $swapcount; //SWAP COUNT"
        echo "  static STAKENODEOPERATOR ="
        echo "    \"0xcf4b9402e7f156bc75082bc07581b0829f081ccfc8c444c71df4536ea33d094a\"; //Operator: Mysten Labs 0"
        echo "  static DISPLAY = \"BLESS\"; // TWIST OR BLESS"
        echo "  static DELAYINHOURS = 24;"
        echo ""
        echo "  // NETWORK"
        echo "  static RPC = {"
        echo "    NETWORK: \"testnet\","
        echo "    EXPLORER: \"https://testnet.suivision.xyz/\","
        echo "  };"
        echo "}"  # Config 클래스 끝
    } > "$WORK/config/config.js"

    # accounts파일 생성
    echo -e "${YELLOW}개인키를 입력하세요. 여러 개의 개인키는 쉼표로 구분해주세요.${NC}"
    echo -e "${YELLOW}프록시의 숫자와 개인키의 숫자가 같아야 합니다.${NC}"
    echo -e "${YELLOW}입력을 마치려면 엔터를 두 번 누르세요.${NC}"

    # 개인키 입력 받기
    read -p "개인키 입력: " keys_input
    # 쉼표로 구분된 개인키를 줄바꿈으로 변환
    {
        echo "export const privateKey = ["  # 파일 시작
        IFS=','  # 구분자를 쉼표로 설정
        first=true  # 첫 번째 요소 여부 확인
        for key in $keys_input; do
            key=$(echo "$key" | xargs)  # 공백 제거
            if [ "$first" = true ]; then
                echo "  \"$key\""
                first=false
            else
                echo "  \"$key\","
            fi
        done
        echo "];"  # 배열 끝
    } > "$WORK/accounts/accounts.js"

    # 봇 구동
    npm run start

    ;;
    
  2)
    echo -e "${GREEN}walrus봇을 재실행합니다.${NC}"
    
    # nvm을 로드합니다
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # nvm을 로드합니다
    cd "$WORK"
    # 봇 구동
    npm run start
    ;;

  *)
    echo -e "${RED}잘못된 선택입니다. 다시 시도하세요.${NC}"
    ;;
esac
