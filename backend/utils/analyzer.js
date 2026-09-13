// =============================================================================
//  FAKE JOB POSTING DETECTION — SCAM ANALYZER
//  Enhanced with extensive training data for:
//    • Fake Job Postings
//    • Phishing / Scam Emails
//    • Scam SMS / WhatsApp Messages
//    • Investment & Lottery Scams
//    • OTP / Banking Fraud
//    • Indian-specific scam patterns
// =============================================================================

const scamPatterns = {

    // -------------------------------------------------------------------------
    //  URGENT / THREATENING LANGUAGE  (score: 10 per match)
    // -------------------------------------------------------------------------
    urgentLanguage: [
        'urgent', 'urgently', 'immediately', 'quick hire', 'hurry', 'hurry up',
        'limited time', 'right away', 'as soon as possible', 'asap',
        'deadline', 'threatening', 'action required', 'act now', 'don\'t delay',
        'last chance', 'final notice', 'exclusive offer expires',
        'respond within 24 hours', 'respond within 48 hours',
        'time sensitive', 'time-sensitive', 'expires today',
        'offer closes soon', 'must act immediately', 'do not ignore',
        'failure to respond', 'account will be suspended', 'account suspended',
        'your account will be closed', 'reply urgently', 'immediate action',
        'within 24 hours', 'within 48 hours', 'within 72 hours',
        'before it\'s too late', 'warning', 'final warning', 'last reminder',
        'overdue notice', 'critical alert', 'attention required',
        // Extended urgent patterns
        'do not delete', 'do not discard', 'do not ignore this',
        'respond immediately', 'reply back immediately', 'contact us now',
        'message us now', 'this is your last opportunity', 'only today',
        'valid for today only', 'expiring soon', 'ends tonight',
        'limited seats', 'limited slots', 'only few slots left',
        'only 10 seats left', 'closing soon', 'closing in 24 hours',
        'your response is awaited', 'awaiting your urgent reply',
        'legal action will be taken', 'legal proceedings initiated',
        'police complaint will be filed', 'arrest warrant issued',
        'your device has been hacked', 'your computer is infected',
        'security breach detected', 'you are being watched',
        'do not turn off your phone', 'stay on the line',
        'do not contact anyone', 'keep silent', 'do not tell anyone'
    ],

    // -------------------------------------------------------------------------
    //  MONEY / FEE REQUESTS  (score: 20 per match)
    // -------------------------------------------------------------------------
    moneyRequests: [
        'security deposit', 'processing fee', 'registration fee', 'training fee',
        'laptop fee', 'laptop deposit', 'equipment fee', 'kit fee', 'starter kit fee',
        'id card fee', 'uniform fee', 'background check fee', 'certification fee',
        'activation fee', 'membership fee', 'joining fee', 'application fee',
        'advance payment', 'refundable deposit', 'send money', 'wire money',
        'payment', 'money', 'transfer money', 'bitcoin', 'crypto', 'cryptocurrency',
        'bank account', 'bank transfer', 'bank details', 'account number',
        'routing number', 'ifsc code', 'micr code', 'swift code',
        'western union', 'moneygram', 'neteller', 'payeer', 'perfect money',
        'google play card', 'itunes gift card', 'amazon gift card', 'gift card',
        'voucher code', 'top up', 'recharge', 'prepaid card',
        'fund your wallet', 'initial investment', 'investment required',
        'down payment', 'upfront payment', 'pay first', 'pay to start',
        'pay to get started', 'deposit required', 'paytm', 'gpay', 'phonepe',
        'upi transfer', 'send via upi', 'neft', 'imps', 'rtgs',
        // Extended money fraud patterns
        'send bitcoin', 'send usdt', 'send eth', 'send dogecoin', 'tether',
        'binance pay', 'coinbase', 'crypto wallet address', 'wallet address',
        'scan qr code to pay', 'pay via qr', 'qr code payment',
        'money order', 'demand draft', 'dd payment', 'cheque payment',
        'cash deposit', 'cash transfer', 'hand over cash',
        'handling charge', 'delivery charge', 'courier charge',
        'insurance charge', 'customs duty', 'import duty', 'clearance charge',
        'admin fee', 'convenience fee', 'transaction fee', 'service charge',
        'refundable after joining', 'will be reimbursed', 'money back guarantee',
        'pay and get refund', 'deposit will be returned', 'fully refundable',
        'send rs', 'send ₹', 'pay ₹', 'pay rs', 'transfer ₹',
        'account details below', 'pay to this account', 'transfer to this number'
    ],

    // -------------------------------------------------------------------------
    //  PERSONAL DATA THEFT  (score: 25 per match)
    // -------------------------------------------------------------------------
    personalData: [
        'otp', 'one time password', 'cvv', 'password', 'pin', 'atm pin',
        'social security', 'ssn', 'bank statement', 'credit card', 'debit card',
        'card number', 'card details', 'expiry date', 'expiration date',
        'mother\'s maiden name', 'date of birth', 'dob', 'aadhar', 'aadhaar',
        'pan card', 'pan number', 'passport number', 'driver\'s license',
        'driving licence', 'voter id', 'ration card', 'uan number',
        'pf account', 'esi number', 'full name and address', 'home address',
        'current address', 'permanent address', 'salary slip', 'bank passbook',
        'cancelled cheque', 'login credentials', 'username and password',
        'share your otp', 'enter otp', 'verify otp', 'otp for kyc',
        'kyc update', 'kyc verification', 'kyc expired', 'complete your kyc',
        'update your kyc', 'link aadhaar', 'biometric', 'fingerprint',
        'net banking password', 'mobile banking pin', 'upi pin', 'mpin',
        // Extended personal data theft patterns
        'selfie with id', 'photo with aadhar', 'photo with pan',
        'live photo', 'live selfie', 'video kyc', 'liveness check',
        'send id proof', 'id proof required', 'identity proof',
        'send address proof', 'address proof required',
        'share bank statement', 'last 3 months statement', '6 months statement',
        'form 16', 'itr copy', 'income tax return copy',
        'electricity bill', 'utility bill', 'gas bill as address proof',
        'rental agreement', 'rent agreement copy',
        'vehicle registration', 'rc book', 'vehicle rc',
        'insurance policy copy', 'policy document',
        'share screen', 'screen share', 'remote access', 'anydesk', 'teamviewer',
        'install anydesk', 'install teamviewer', 'install remote app',
        'allow access to phone', 'give phone access', 'mobile access',
        'two step code', '2fa code', 'authenticator code', 'backup code',
        'recovery code', 'secret question', 'security answer'
    ],

    // -------------------------------------------------------------------------
    //  FREE EMAIL DOMAINS — used unprofessionally by fake employers
    // -------------------------------------------------------------------------
    freeDomains: [
        'gmail.com', 'yahoo.com', 'outlook.com', 'hotmail.com', 'aol.com',
        'protonmail.com', 'ymail.com', 'rediffmail.com', 'mail.com',
        'inbox.com', 'zoho.com', 'icloud.com', 'me.com', 'live.com',
        'msn.com', 'rocketmail.com', 'email.com', 'fastmail.com',
        'tutanota.com', 'mailfence.com'
    ],

    // -------------------------------------------------------------------------
    //  GENERIC FAKE JOB PHRASES  (score: 15 per match)
    // -------------------------------------------------------------------------
    fakeJobPhrases: [
        'work from home', 'work at home', 'work from anywhere',
        'earn from home', 'earn money from home', 'earn daily',
        'earn weekly', 'earn monthly', 'unlimited earning', 'unlimited income',
        'high salary', 'attractive salary', 'guaranteed salary',
        'no experience needed', 'no experience required', 'freshers welcome',
        'no qualification required', 'no skills required', 'any graduate',
        'any degree', 'open to all', 'all are welcome',
        'flexible hours', 'flexible timing', 'part time job',
        'part-time work', 'home based job', 'home based work',
        'data entry', 'simple typing job', 'online typing work',
        'copy paste job', 'form filling job', 'captcha solving',
        'whatsapp us', 'contact on whatsapp', 'whatsapp only',
        'join our telegram', 'telegram group', 'telegram channel',
        'contact on telegram', 'message on whatsapp',
        'quick money', 'easy money', 'fast money', 'make money fast',
        'earn 5000 per day', 'earn 10000 per day', 'earn 50000 per month',
        'earn lakhs', 'earn in thousands', '100% job guarantee',
        'guaranteed placement', 'guaranteed income', 'guaranteed returns',
        'no target', 'no pressure', 'no boss', 'be your own boss',
        'multi level marketing', 'mlm', 'network marketing', 'direct selling',
        'chain marketing', 'team building', 'referral bonus',
        'refer and earn', 'join and earn', 'signup bonus',
        'hiring urgently', 'urgent vacancy', 'mass hiring',
        'walk-in interview', 'spot offer', 'on the spot offer',
        'direct selection', 'no interview', 'no written test',
        'call hr', 'call this number', 'contact hr directly',
        'avoid scams', 'genuine job', 'real work', '100% genuine',
        'no fraud', 'verified company',
        // Extended fake job patterns
        'youtube job', 'youtube task', 'like and subscribe job',
        'instagram job', 'instagram task', 'facebook job', 'social media task',
        'ad posting job', 'post ads and earn', 'advertisement posting',
        'image uploading job', 'photo editing job simple',
        'product review job', 'write reviews and earn',
        'amazon review job', 'flipkart review job', 'e-commerce review',
        'online survey job', 'fill surveys earn', 'paid surveys',
        'micro task job', 'micro jobs online', 'small task big pay',
        'housewife job', 'students job', 'retired person job',
        'senior citizen income', 'earn at your age',
        'work 2 hours daily', 'work 3 hours earn', 'work from bed',
        'work while travelling', 'work from any device',
        'earn on mobile', 'earn through app', 'install app and earn',
        'download app earn money', 'app based earning',
        'telegram task job', 'discord task', 'task channel',
        'prepaid task', 'advance task payment', 'daily task payment',
        'target based income', 'no target just earn',
        'government approved job', 'government certified',
        'rbi approved', 'sebi registered job', 'iso certified company',
        'mnc hiring', 'fortune 500 hiring', 'top company hiring',
        'immediate joining', 'join today start earning',
        'training will be provided', 'free training',
        'no training required', 'no degree required',
        'just a smartphone', 'laptop not required', 'no pc needed'
    ],

    // -------------------------------------------------------------------------
    //  SCAM EMAIL PATTERNS  (score: 18 per match)
    // -------------------------------------------------------------------------
    emailScamPhrases: [
        'dear friend', 'dear beneficiary', 'dear winner', 'dear customer',
        'dear account holder', 'dear valued customer', 'dear sir/madam',
        'lottery winner', 'you have won', 'congratulations you have been selected',
        'inheritance fund', 'inheritance claim', 'unclaimed inheritance',
        'foreign funds', 'unclaimed funds', 'dormant account',
        'unclaimed prize', 'claim your prize', 'claim your winnings',
        'nigerian prince', 'nigerian attorney', 'west african', 'barrister',
        'solicitor seeks your help', 'partnership proposal',
        'wire transfer', 'fund transfer', 'bank to bank transfer',
        'transfer of funds', 'assist in transferring',
        'confirm your account', 'verify your identity', 'verify your account',
        'click here to verify', 'click the link below', 'login to verify',
        'your account has been suspended', 'temporary suspension',
        'update your billing', 'update payment method', 'payment failed',
        'your subscription has expired', 'renew your subscription',
        'you have been selected', 'specially selected', 'randomly selected',
        'million dollar', 'billion dollar', 'reward of', 'prize money',
        'prize worth', 'cash prize', 'reward money',
        'please respond', 'keep this confidential', 'do not share',
        'this is not a scam', 'this is legitimate', '100% safe',
        'God bless', 'God bless you', 'may God bless',
        'urgent reply needed', 'awaiting your reply', 'waiting for your response',
        'investment opportunity', 'business proposal', 'business offer',
        'from the desk of', 'on behalf of', 'i am the attorney of',
        'i am writing to inform you', 'it is with great pleasure',
        'charity donation', 'goodwill donation', 'humanitarian funds',
        'compensation claim', 'government compensation', 'rbi compensation',
        'income tax refund', 'tax refund', 'income tax department',
        'irs notice', 'customs clearance', 'package held at customs',
        'package delivery failed', 'failed delivery attempt',
        'phishing link', 'reset your password', 'password reset request',
        'unauthorized login attempt', 'suspicious login detected',
        'two factor authentication', 'security alert', 'fraud alert',
        'you are shortlisted', 'your profile is selected',
        'overseas job offer', 'foreign job offer', 'dubai job', 'canada job',
        'uk visa sponsorship', 'australia job offer', 'work visa sponsored',
        'hotel job abroad', 'nanny job abroad', 'driver job abroad',
        // Extended email scam patterns
        'we have been trying to reach you', 'multiple attempts to contact',
        'this is our final attempt', 'last attempt to notify',
        'your email was randomly picked', 'your email address won',
        'open an attached file', 'see attached document', 'open the attachment',
        'microsoft support', 'apple support team', 'google security team',
        'amazon order cancelled', 'amazon account locked', 'netflix suspended',
        'paypal limited', 'paypal account restricted', 'ebay account suspended',
        'bank of america', 'chase bank verification', 'wells fargo alert',
        'federal bureau', 'fbi notice', 'interpol notice', 'united nations',
        'world bank grant', 'imf compensation', 'african development bank',
        'ceo fraud', 'cfo request', 'director request transfer',
        'spoofed email', 'impersonation attempt', 'executive impersonation',
        'we are pleased to inform', 'we hereby notify',
        'your parcel is on hold', 'package requires fee', 'redex tracking',
        'fedex package', 'ups delivery fee', 'dhl customs duty',
        'job offer letter attached', 'appointment letter enclosed',
        'offer letter from', 'contract attached for signing',
        'sign the contract', 'digitally sign below', 'e-sign required',
        'you are hired', 'you got the job', 'interview cleared',
        'work permit ready', 'employment visa', 'visa processing fee',
        'air ticket arrangement', 'relocation allowance', 'accommodation arranged'
    ],

    // -------------------------------------------------------------------------
    //  SCAM SMS / WHATSAPP MESSAGE PATTERNS  (score: 18 per match)
    // -------------------------------------------------------------------------
    messageScamPhrases: [
        'you have won a prize', 'you have won a lottery', 'you won',
        'congratulations! you', 'congrats! you have',
        'click the link', 'click here', 'tap here', 'open this link',
        'visit this link', 'follow this link',
        'claim your reward', 'claim your prize', 'claim now',
        'free gift', 'get a free', 'free iphone', 'free laptop',
        'free recharge', 'free data', 'free cashback',
        'otp is', 'your otp is', 'otp for', 'share this otp',
        'do not share otp', 'never share otp',
        'sms alert', 'bank sms', 'alert from bank',
        'recharge now', 'recharge today', 'top up now',
        'whatsapp group link', 'join whatsapp group', 'telegram link',
        'earn daily', 'earn per day', 'earn per week',
        'refer friends', 'refer and earn', 'invite friends',
        'part time job available', 'online job available',
        'investment plan', 'investment opportunity',
        'double your money', 'triple your money', 'money doubling',
        'guaranteed profit', 'guaranteed returns', 'high returns',
        'fixed returns', 'risk free investment', 'no risk',
        'kyc update sms', 'your account will be blocked',
        'block will be lifted', 'unblock your account',
        'sim card blocked', 'sim card deactivated', 'sim blocked',
        'your number will be deactivated', 'reactivate your number',
        'call this number immediately', 'call now', 'call back',
        'sbi alert', 'hdfc alert', 'icici alert', 'axis alert',
        'kotak alert', 'pnb alert', 'bob alert', 'canara bank',
        'paytm alert', 'phonepe alert', 'gpay alert', 'upi alert',
        'amazon sale', 'flipkart prize', 'meesho income',
        'byjus job', 'swiggy partner', 'zomato delivery',
        'ola driver income', 'uber partner earn',
        'fill this form', 'complete this survey', 'answer a survey',
        'win rs', 'win inr', 'win rupees', 'win cash',
        'lucky draw winner', 'lucky winner', 'selected as winner',
        'spin and win', 'scratch and win', 'play and win',
        'you are pre-approved', 'loan approved', 'instant loan',
        'personal loan offer', 'credit card offer', 'upgrade your card',
        'insurance claim', 'claim insurance', 'policy matured',
        // Extended SMS / WhatsApp scam patterns
        'your jio number', 'your airtel number', 'your bsnl number',
        'your sim will expire', 'port your number', 'sim upgrade required',
        'esim activation', 'esim upgrade', 'sim card upgrade fee',
        'trai order', 'trai directive', 'telecom authority',
        'happy hours offer', 'flash sale offer', 'mega sale today',
        'bumper offer', 'festival offer', 'diwali offer', 'christmas offer',
        'new year offer', 'limited period offer', 'today only offer',
        'your electricity bill', 'electricity disconnection', 'power cut warning',
        'bijli vibhag', 'bescom notice', 'tneb notice', 'msedcl notice',
        'gas supply disconnection', 'lpg cylinder issue',
        'water supply notice', 'municipality notice',
        'traffic challan', 'e-challan notice', 'fine to be paid',
        'parivahan notice', 'rto notice', 'driving license penalty',
        'court hearing notice', 'summons issued', 'complaint registered against you',
        'cyber crime notice', 'cyber police',
        'stock market alert', 'share buying tip', 'buy these shares',
        'mutual fund alert', 'sip doubling scheme', 'nps fraud',
        'bank job offer sms', 'post office job', 'railway job', 'ssc job',
        'government job sms', 'defence job offer', 'army job offer',
        'job offer without exam', 'job without interview sms',
        'task completed pay now', 'release payment', 'unlock earnings'
    ],

    // -------------------------------------------------------------------------
    //  INVESTMENT / CRYPTO SCAM PATTERNS  (score: 22 per match)
    // -------------------------------------------------------------------------
    investmentScamPhrases: [
        'guaranteed profit', 'guaranteed returns', 'assured returns',
        'fixed returns', 'daily profit', 'weekly profit', 'monthly profit',
        'passive income', 'passive earning', 'automatic income',
        'autopilot income', 'money works for you', 'money while you sleep',
        'high return investment', 'highest return', 'maximum returns',
        'double your money', 'triple your investment', '2x your money',
        'bitcoin investment', 'crypto investment', 'ethereum investment',
        'forex trading', 'forex investment', 'binary options',
        'stock tips', 'stock market tips', 'share market tips',
        'insider tips', 'sure shot tips', 'intraday tips',
        'ponzi scheme', 'pyramid scheme', 'chit fund scheme',
        'mlm scheme', 'network marketing scheme',
        'invest now', 'invest today', 'start investing',
        'minimum investment', 'invest as low as', 'start with',
        'withdraw anytime', 'instant withdrawal', 'daily withdrawal',
        'referral income', 'referral bonus', 'downline income',
        'matrix plan', 'binary plan', 'auto pool',
        'crowdfunding', 'cloud mining', 'crypto mining',
        'trading bot', 'auto trading', 'trading robot',
        'nft investment', 'metaverse land', 'defi project',
        'ipo allotment', 'ipo refund', 'ipo application',
        // Extended investment scam patterns
        'p2p lending fraud', 'peer to peer scam', 'lending app scam',
        'app based investment', 'invest in our app', 'trading app guaranteed',
        'telegram investment channel', 'whatsapp investment group',
        'expert trader tips', 'certified trader', 'sebi expert tips',
        'gold investment scheme', 'gold price guarantee', 'digital gold scam',
        'silver investment', 'commodity trading tips',
        'real estate investment scam', 'plot scam', 'land investment scam',
        'virtual real estate', 'metaverse plot', 'virtual land',
        'usdt trading', 'binance signals', 'crypto signals group',
        'pump and dump', 'pump group', 'token launch scam',
        'pre ipo investment', 'unlisted shares buy', 'grey market premium',
        'fixed deposit 20%', 'fd with 30% interest', 'high interest fd',
        'recurring deposit scam', 'rd scam', 'post office scheme scam',
        'kisan vikas patra fraud', 'nsc fraud', 'sukanya scam',
        'earn 1% daily', 'earn 2% daily', 'daily roi', 'monthly roi',
        '10x returns', '20x returns', '100x returns',
        'no risk guaranteed', 'zero risk', 'risk-free profit',
        'hedge fund access', 'private equity scam', 'venture fund fraud'
    ],

    // -------------------------------------------------------------------------
    //  ROMANCE / SOCIAL ENGINEERING SCAM  (score: 20 per match)
    // -------------------------------------------------------------------------
    romanceScamPhrases: [
        'i am in love with you', 'i love you already', 'you are my soulmate',
        'i want to meet you', 'let us meet soon', 'come to my country',
        'i am stuck abroad', 'i am stranded', 'medical emergency abroad',
        'i need your help', 'please help me', 'only you can help',
        'send me money', 'send money via', 'money transfer please',
        'i will repay you', 'i will pay back', 'i promise to repay',
        'gift coming for you', 'parcel stuck in customs',
        'customs fee to release', 'release my package',
        'you are so beautiful', 'you look gorgeous', 'you are special to me',
        'we met online', 'online friendship', 'social media friend',
        'dating site', 'online dating', 'tinder match',
        'i am a soldier', 'i am deployed', 'military deployment',
        'un mission', 'peacekeeping mission', 'offshore oil rig',
        // Extended romance / pig butchering scam patterns
        'i found you on', 'i saw your profile', 'you look interesting',
        'let us be friends', 'can we be friends', 'i am lonely',
        'i lost my wife', 'i lost my husband', 'widower looking',
        'i am a doctor', 'i am an engineer abroad', 'works overseas',
        'i am a pilot', 'i work on a ship', 'merchant navy',
        'i will visit you soon', 'planning to come to india',
        'let us video call', 'send me your photos', 'send private photos',
        'i have feelings for you', 'i miss you already', 'you are my everything',
        'share your location', 'what is your address', 'where do you live exactly',
        'pig butchering scam', 'crypto romance scam', 'investment romance',
        'i made profit let me teach you', 'my friend is a trader',
        'join my trading group', 'i will help you earn',
        'hospital bill abroad', 'surgery fee needed', 'medical fee emergency',
        'embassy fee', 'flight ticket to visit you', 'ticket money needed'
    ],

    // -------------------------------------------------------------------------
    //  LOTTERY / PRIZE SCAM PATTERNS  (score: 20 per match)
    // -------------------------------------------------------------------------
    lotteryScamPhrases: [
        'you have been selected', 'randomly selected', 'computer ballot',
        'email lottery', 'international lottery', 'global lottery',
        'uk national lottery', 'euro lottery', 'mega jackpot',
        'powerball winner', 'mega millions winner',
        'lucky mobile number', 'lucky email address', 'lucky draw',
        'prize of', 'prize worth', 'cash prize of', 'awarded to you',
        'claim before expiry', 'claim within 3 days', 'claim within 7 days',
        'lottery ticket number', 'reference number', 'batch number',
        'serial number', 'winning number is',
        'tax on winnings', 'clearance fee', 'processing charge to claim',
        'to collect prize', 'to receive your winnings', 'to claim reward',
        // Extended lottery / prize scam patterns
        'kbc lottery', 'kbc winner', 'kaun banega crorepati lottery',
        'jio lottery winner', 'airtel lottery', 'bsnl lucky draw',
        'modi government lottery', 'pm lottery scheme', 'government prize',
        'covid relief fund winner', 'corona relief prize',
        'amazon lucky draw', 'flipkart lucky winner', 'paytm lottery',
        'facebook lottery', 'whatsapp lottery', 'youtube lottery winner',
        'google lucky winner', 'microsoft lottery', 'apple lottery winner',
        'your number selected', 'your phone number selected for prize',
        'you are the 1 millionth visitor', 'you are the lucky visitor',
        'spinning wheel result', 'you won the spin', 'your spin result',
        'redeem your prize', 'prize redemption form', 'collect award',
        'winner certificate', 'prize certificate attached',
        'prize delivery charge', 'award dispatch fee', 'courier for prize',
        '1 crore prize', '50 lakh prize', '25 lakh lottery', '10 lakh winner',
        'prize money in escrow', 'prize held at customs',
        'prize agent', 'claim agent', 'lottery agent fee'
    ],

    // -------------------------------------------------------------------------
    //  INDIAN-SPECIFIC KYC / GOVERNMENT SCAM PATTERNS  (score: 22 per match)
    // -------------------------------------------------------------------------
    indianScamPhrases: [
        'aadhaar link', 'link aadhaar with pan', 'pan aadhaar linking',
        'aadhaar update', 'aadhaar verify', 'aadhaar kyc',
        'pan card update', 'pan verification', 'update pan',
        'income tax notice', 'income tax refund pending', 'it refund',
        'tds refund', 'gst refund', 'gst notice',
        'epf withdrawal', 'pf withdrawal', 'uan activation',
        'esi claim', 'provident fund transfer',
        'pm kisan', 'pm awas yojana', 'pm mudra loan',
        'pm jan dhan', 'ayushman bharat', 'sarkari yojana',
        'government scheme benefit', 'government grant',
        'rbi regulation', 'rbi notice', 'rbi lottery',
        'sebi registered', 'sebi approved', 'irda approved',
        'nabard loan', 'sidbi loan', 'mudra loan scheme',
        'msme loan', 'start up india loan', 'stand up india',
        'sim card kyc', 'trai notice', 'trai regulation',
        'bsnl notice', 'jio kyc', 'airtel kyc', 'vi kyc',
        'court notice', 'police case', 'cyber crime complaint',
        'arrest warrant', 'ed notice', 'cbi notice',
        'narcotics case', 'money laundering case', 'it raid',
        'digital arrest', 'freeze your account', 'bank account frozen',
        'suspicious transaction', 'your account is under investigation'
    ],

    // -------------------------------------------------------------------------
    //  SUSPICIOUS CONTACT METHODS
    // -------------------------------------------------------------------------
    suspiciousContact: [
        'whatsapp only', 'only on whatsapp', 'contact via whatsapp',
        'telegram only', 'only on telegram', 'signal only',
        'no calls please', 'sms only', 'chat only',
        'personal email', 'contact me personally', 'personal number',
        'call after hours', 'available after 10 pm',
        'foreign number', 'international code', '+1 ', '+44 ', '+234 ',
        '+971 ', '+61 ', '+1800', 'toll free number',
        'google form link', 'typeform link', 'jotform link',
        'fill the google form', 'registration form link',
        'apply via link', 'apply on this link', 'register now on this link',
        'no official website', 'website under construction',
        'contact directly', 'reach out personally'
    ],

    // -------------------------------------------------------------------------
    //  TOO GOOD TO BE TRUE JOB OFFERS  (score: 15 per match)
    // -------------------------------------------------------------------------
    unrealisticOffers: [
        'earn 50000 monthly', 'earn 1 lakh monthly', 'earn 2 lakh monthly',
        'earn lakhs from home', 'salary 1 lakh per month',
        'salary upto 5 lakh', 'salary negotiable no limit',
        'no work experience required for high salary',
        'freshers earn 60000', 'freshers earn 80000',
        'earn 5000 per day from mobile', 'earn from mobile',
        'earn from android phone', 'earn from smartphone',
        'no investment required earn daily',
        'earn without any skill', 'zero skill job',
        'work 1 hour a day earn', 'work 2 hours earn',
        'just share posts and earn', 'just watch ads and earn',
        'just click ads and earn', 'just like posts and earn',
        '500 per hour', '1000 per hour', '2000 per hour',
        'daily payment guaranteed', 'same day payment',
        'instant payout', 'payout daily', 'payout hourly'
    ],

    // -------------------------------------------------------------------------
    //  LEGITIMATE JOB KEYWORDS — used to confirm valid job posts
    // -------------------------------------------------------------------------
    legitimateJobKeywords: [
        'apply now', 'job description', 'key responsibilities', 'responsibilities',
        'qualifications', 'minimum qualifications', 'preferred qualifications',
        'requirements', 'experience required', 'years of experience',
        'salary', 'compensation', 'benefits', 'perks', 'leave policy',
        'health insurance', 'pf', 'esic', 'gratuity',
        'location', 'office location', 'job location', 'onsite', 'remote', 'hybrid',
        'full time', 'full-time', 'permanent role', 'contract role',
        'interview process', 'technical round', 'hr round', 'panel interview',
        'resume', 'cv', 'portfolio', 'cover letter',
        'human resources', 'hr team', 'talent acquisition', 'recruiter',
        'department', 'team structure', 'reporting to', 'job title',
        'designation', 'role', 'vacancy', 'opening', 'position',
        'candidate', 'ideal candidate', 'we are looking for',
        'skills required', 'technical skills', 'soft skills',
        'education', 'degree', 'bachelor', 'master', 'mba', 'btech',
        'mtech', 'mca', 'bca', 'bsc', 'msc', 'phd',
        'company overview', 'about us', 'about the company', 'our team',
        'equal opportunity employer', 'eoe', 'diversity', 'inclusion',
        'probation period', 'notice period', 'joining date', 'start date',
        'ctc', 'cost to company', 'in hand salary', 'take home',
        'appraisal', 'performance review', 'kra', 'kpi',
        'team player', 'communication skills', 'problem solving',
        'analytical skills', 'leadership', 'management skills'
    ],

    // -------------------------------------------------------------------------
    //  LEGITIMATE EMAIL KEYWORDS — used to distinguish real business emails
    // -------------------------------------------------------------------------
    legitimateEmailKeywords: [
        'as per our discussion', 'as discussed', 'following up',
        'please find attached', 'please find enclosed', 'kindly find',
        'meeting scheduled', 'calendar invite', 'agenda for meeting',
        'minutes of meeting', 'mom', 'action items',
        'project update', 'status update', 'progress report',
        'invoice', 'purchase order', 'quotation', 'proposal',
        'thank you for', 'thanks for', 'appreciate your',
        'regards', 'warm regards', 'best regards', 'sincerely',
        'looking forward to', 'please revert', 'please respond',
        'at your earliest convenience', 'as soon as possible',
        'please confirm', 'confirmation required', 'please acknowledge',
        'quarterly report', 'annual report', 'financial statement',
        'compliance', 'policy', 'procedure', 'guideline',
        'notification', 'reminder', 'follow up', 'fyi', 'for your information'
    ]
};

// =============================================================================
//  CONTENT TYPE DETECTOR
// =============================================================================
const detectContentType = (text) => {
    const lower = text.toLowerCase();

    // Email indicators
    const emailIndicators = [
        'subject:', 'from:', 'to:', 'cc:', 'bcc:', 'dear ', 'regards,',
        'sincerely,', 'yours truly', 'yours sincerely', 'best regards',
        'warm regards', 'unsubscribe', 'reply to', 'reply-to',
        'forwarded message', 'original message', 'sent from', '@', 'gmail', 'yahoo'
    ];
    const emailScore = emailIndicators.filter(p => lower.includes(p)).length;

    // SMS/WhatsApp/Chat indicators
    const msgIndicators = [
        'hi ', 'hello ', 'hey ', 'sms', 'msg', 'reply stop', 'call us',
        'click the link', 'whatsapp', 'telegram', 'click here',
        'otp is', 'your otp', 'bank alert', 'sbi:', 'hdfc:', 'icici:',
        'dear customer', 'mobile number', 'rs.', '₹', 'inr', 'rupees'
    ];
    const msgScore = msgIndicators.filter(p => lower.includes(p)).length;

    // Job post indicators
    const jobScore = scamPatterns.legitimateJobKeywords.filter(p => lower.includes(p)).length;

    // Strong email markers
    if (emailScore >= 2 || lower.includes('subject:') || lower.includes('from:')) return 'email';
    // Strong message markers
    if (msgScore >= 2 || lower.includes('otp') || lower.includes('whatsapp')) return 'message';
    // Likely a job posting
    if (jobScore >= 2) return 'job';

    // Weak signals — fall back on what scores highest
    if (emailScore > msgScore && emailScore > jobScore) return 'email';
    if (msgScore > emailScore && msgScore > jobScore) return 'message';
    if (jobScore > 0) return 'job';

    return 'unknown';
};

// =============================================================================
//  GIBBERISH / INVALID INPUT DETECTOR
// =============================================================================
const isGibberish = (text) => {
    const trimmed = text.trim();
    if (!trimmed) return true;

    // Minimum meaningful length
    if (trimmed.length < 10) return true;

    const words = trimmed.split(/\s+/).filter(Boolean);

    // Check vowel ratio — English text is ~30-60% vowels
    const letters = trimmed.match(/[a-zA-Z]/g) || [];
    const vowels = trimmed.match(/[aeiouAEIOU]/g) || [];

    if (letters.length > 5) {
        const vowelRatio = vowels.length / letters.length;
        if (vowelRatio < 0.10 || vowelRatio > 0.90) return true;
    }

    // If a single "word" and it's long random characters → gibberish
    if (words.length === 1 && trimmed.length > 8 && /^[a-z0-9]+$/i.test(trimmed)) return true;

    // Too many non-alpha characters (mostly numbers/symbols, no real words)
    const alphaRatio = letters.length / trimmed.length;
    if (trimmed.length > 10 && alphaRatio < 0.35) return true;

    // All words are very short (1-2 chars) with no meaning
    const avgWordLen = words.reduce((sum, w) => sum + w.length, 0) / (words.length || 1);
    if (words.length > 3 && avgWordLen < 2) return true;

    // Consecutive same character spam: aaaaaaa, 111111
    if (/(.)\1{5,}/.test(trimmed)) return true;

    return false;
};

// =============================================================================
//  STRUCTURED EXPLANATION GENERATOR
// =============================================================================
const buildStructuredExplanation = ({
    classification,
    isInvalidInput = false,
    urgentMatches = [],
    moneyMatches = [],
    dataMatches = [],
    fakeJobMatches = [],
    emailScamMatches = [],
    msgScamMatches = [],
    investMatches = [],
    romanceMatches = [],
    lotteryMatches = [],
    indianMatches = [],
    contactMatches = [],
    unrealMatches = [],
    freeEmailMatches = [],
    matchedShortUrls = []
}) => {
    if (isInvalidInput) {
        return {
            summary: 'The entered text appears to be random characters, too short, or meaningless. Meaningful scam analysis could not be performed.',
            categories: [],
            overallAdvice: 'Please provide a valid job description, email, or message for proper analysis.',
            mlAssessment: null
        };
    }

    const categories = [];

    // 1. Upfront Fee / Payment Request (CRITICAL)
    if (moneyMatches.length > 0) {
        categories.push({
            category: 'Upfront Fee / Payment Request',
            severity: 'CRITICAL',
            evidence: [...new Set(moneyMatches)],
            whySuspicious: 'Legitimate employers and recruitment agencies generally do not require candidates to pay application fees, security deposits, training charges, or kit costs.',
            recommendedAction: 'Do not transfer money or pay recruitment-related fees via UPI, wire transfer, or gift cards.'
        });
    }

    // 2. Sensitive Information Request (CRITICAL)
    if (dataMatches.length > 0) {
        categories.push({
            category: 'Sensitive Information Request',
            severity: 'CRITICAL',
            evidence: [...new Set(dataMatches)],
            whySuspicious: 'Requesting OTPs, banking credentials, CVVs, Aadhaar/PAN details, or installation of remote-desktop apps (AnyDesk/TeamViewer) poses extreme risks of identity theft and bank fraud.',
            recommendedAction: 'Do not share OTPs, passwords, banking credentials, or identity documents. Never install remote-access software.'
        });
    }

    // 3. Government / Legal Impersonation (CRITICAL)
    if (indianMatches.length > 0) {
        categories.push({
            category: 'Government / Legal Impersonation',
            severity: 'CRITICAL',
            evidence: [...new Set(indianMatches)],
            whySuspicious: 'Impersonating government or regulatory authorities (such as RBI, CBI, Police, or Tax Department) and threatening legal action or "digital arrest" is an intimidation tactic used to induce compliance.',
            recommendedAction: 'Official government authorities never demand immediate payments or issue legal threats via messaging apps. Report threats to cybercrime authorities.'
        });
    }

    // 4. Investment Scam Pattern (CRITICAL)
    if (investMatches.length > 0) {
        categories.push({
            category: 'Investment Scam Pattern',
            severity: 'CRITICAL',
            evidence: [...new Set(investMatches)],
            whySuspicious: 'Guaranteed high returns, daily trading bot profits, and unregulated cryptocurrency doubling schemes are hallmarks of financial and Ponzi fraud.',
            recommendedAction: 'Never transfer funds to unregistered investment schemes or trust promises of risk-free, guaranteed returns.'
        });
    }

    // 5. Urgency / Artificial Pressure (HIGH)
    if (urgentMatches.length > 0) {
        categories.push({
            category: 'Urgency / Artificial Pressure',
            severity: 'HIGH',
            evidence: [...new Set(urgentMatches)],
            whySuspicious: 'Scammers often manufacture artificial deadlines or threatening warnings to pressure victims into acting hastily before they have time to verify the offer.',
            recommendedAction: 'Do not make rushed decisions under artificial deadlines. Pause and independently verify the organization through official channels.'
        });
    }

    // 6. Suspicious Job Pattern (HIGH)
    if (fakeJobMatches.length > 0) {
        categories.push({
            category: 'Suspicious Job Pattern',
            severity: 'HIGH',
            evidence: [...new Set(fakeJobMatches)],
            whySuspicious: 'Phrases involving simple typing, data entry tasks, YouTube liking, or direct hiring without formal interviews frequently indicate fraudulent employment schemes.',
            recommendedAction: 'Independently verify job openings directly on the employer\'s official careers portal.'
        });
    }

    // 7. Suspicious Contact Method (HIGH)
    if (contactMatches.length > 0) {
        categories.push({
            category: 'Suspicious Contact Method',
            severity: 'HIGH',
            evidence: [...new Set(contactMatches)],
            whySuspicious: 'Conducting recruitment exclusively over personal messaging platforms (such as WhatsApp or Telegram) or unverified web forms circumvents official corporate oversight.',
            recommendedAction: 'Insist on official corporate communication channels and verify recruiter identities via official company directories.'
        });
    }

    // 8. Unrealistic Compensation Offer (HIGH)
    if (unrealMatches.length > 0) {
        categories.push({
            category: 'Unrealistic Compensation Offer',
            severity: 'HIGH',
            evidence: [...new Set(unrealMatches)],
            whySuspicious: 'Unusually high compensation promised for low-skill tasks with no prior experience or qualifications is a common lure used in employment fraud.',
            recommendedAction: 'Compare the offered compensation against industry standard salary benchmarks for equivalent roles.'
        });
    }

    // 9. Obfuscated / Shortened Link (HIGH)
    if (matchedShortUrls.length > 0) {
        categories.push({
            category: 'Obfuscated / Shortened Link',
            severity: 'HIGH',
            evidence: [...new Set(matchedShortUrls)],
            whySuspicious: 'Shortened URLs obscure the actual destination website, commonly redirecting victims to credential-harvesting phishing portals or malware.',
            recommendedAction: 'Avoid opening shortened links from unknown senders; independently verify destination URLs.'
        });
    }

    // 10. Lottery / Prize Scam (HIGH)
    if (lotteryMatches.length > 0) {
        categories.push({
            category: 'Lottery / Prize Scam',
            severity: 'HIGH',
            evidence: [...new Set(lotteryMatches)],
            whySuspicious: 'Notifications claiming lottery or prize winnings for contests never entered—especially when demanding a processing or delivery fee—are fraudulent.',
            recommendedAction: 'Disregard unexpected prize notices. Legitimate lotteries never require winners to pay processing fees in advance.'
        });
    }

    // 11. Romance / Social Engineering Pattern (HIGH)
    if (romanceMatches.length > 0) {
        categories.push({
            category: 'Romance / Social Engineering Pattern',
            severity: 'HIGH',
            evidence: [...new Set(romanceMatches)],
            whySuspicious: 'Sudden emotional appeals followed by requests for financial assistance, airport customs release fees, or emergency aid are common in romance fraud.',
            recommendedAction: 'Never send funds or assist in transferring money for individuals met exclusively online.'
        });
    }

    // 12. Suspicious Email Pattern (HIGH)
    if (emailScamMatches.length > 0) {
        categories.push({
            category: 'Suspicious Email Pattern',
            severity: 'HIGH',
            evidence: [...new Set(emailScamMatches)],
            whySuspicious: 'Classic scam email indicators such as unexpected inheritance claims, account suspension alerts, or generic greetings indicate phishing or advance-fee fraud.',
            recommendedAction: 'Do not reply or click links in unexpected security warnings or inheritance proposals.'
        });
    }

    // 13. Suspicious Message Pattern (HIGH)
    if (msgScamMatches.length > 0) {
        categories.push({
            category: 'Suspicious Message Pattern',
            severity: 'HIGH',
            evidence: [...new Set(msgScamMatches)],
            whySuspicious: 'SMS and messaging alerts claiming imminent SIM deactivation, utility disconnection, or uncollected rewards are designed to induce panic and steal credentials.',
            recommendedAction: 'Verify any account alerts directly through official service provider apps or customer service hotlines.'
        });
    }

    // 14. Suspicious Recruiter Email Domain (MEDIUM)
    if (freeEmailMatches.length > 0) {
        categories.push({
            category: 'Suspicious Recruiter Email Domain',
            severity: 'MEDIUM',
            evidence: [...new Set(freeEmailMatches)],
            whySuspicious: 'Free webmail domains (@gmail, @yahoo, @outlook) can be registered anonymously and may be used by bad actors impersonating corporate recruiters.',
            recommendedAction: 'Verify whether the sender is writing from a verified corporate domain. Contact the company\'s official HR department directly.'
        });
    }

    // Generate user-friendly summary
    let summary;
    const lowerClass = (classification || '').toLowerCase();
    if (lowerClass.includes('scam') || lowerClass.includes('fake')) {
        summary = 'This content contains multiple indicators commonly associated with fraudulent activity. Review the evidence below before taking any action.';
    } else if (lowerClass.includes('suspicious')) {
        summary = 'This content exhibits suspicious patterns that warrant caution. Review the identified indicators before proceeding.';
    } else {
        summary = 'No major scam indicators were detected by the current detection system. Continue to verify important job offers through official company channels.';
    }

    // Generate dynamic overall safety advice
    const adviceItems = [];
    if (moneyMatches.length > 0) {
        adviceItems.push('Do not send money, wire funds, or pay recruitment fees.');
    }
    if (dataMatches.length > 0) {
        adviceItems.push('Do not share OTPs, passwords, banking credentials, or sensitive identity documents.');
    }
    if (urgentMatches.length > 0) {
        adviceItems.push('Do not make rushed decisions under artificial deadlines; verify the employer independently.');
    }
    if (contactMatches.length > 0) {
        adviceItems.push('Insist on communicating through official corporate email addresses rather than messaging apps.');
    }
    if (matchedShortUrls.length > 0) {
        adviceItems.push('Avoid opening shortened links and independently verify destination URLs.');
    }
    if (indianMatches.length > 0) {
        adviceItems.push('Remember that government and regulatory authorities never issue threats or demand money over messaging apps.');
    }
    if (investMatches.length > 0) {
        adviceItems.push('Never invest funds in schemes promising guaranteed profits or zero risk.');
    }
    if (unrealMatches.length > 0 || fakeJobMatches.length > 0) {
        adviceItems.push('Verify the job vacancy directly on the organization\'s official corporate website.');
    }
    if (freeEmailMatches.length > 0) {
        adviceItems.push('Confirm recruiter authenticity directly with the company\'s official HR department.');
    }
    if (lotteryMatches.length > 0) {
        adviceItems.push('Do not pay processing fees to claim unexpected lottery or contest prizes.');
    }
    if (romanceMatches.length > 0) {
        adviceItems.push('Never transfer money to individuals met online who claim customs or medical emergencies.');
    }

    const overallAdvice = adviceItems.length > 0
        ? adviceItems.join(' ')
        : 'Continue to verify important job offers through official company channels and verify recruiter credentials on professional networks.';

    return {
        summary,
        categories,
        overallAdvice,
        mlAssessment: null
    };
};

// =============================================================================
//  MAIN ANALYSIS FUNCTION
// =============================================================================
const analyzeScamContent = (text) => {
    // --- Step 1: Gibberish / Invalid Input Check ---
    if (isGibberish(text)) {
        return {
            classification: '⚠️ Invalid Input',
            contentType: 'unknown',
            contentTypeLabel: 'Unknown Content',
            indicators: [
                'The entered text appears to be random characters, too short, or meaningless. Please provide a valid job description, email, or message for proper analysis.'
            ],
            confidenceScore: 0,
            companyName: 'N/A',
            appLink: 'N/A',
            extractedText: text,
            isInvalidInput: true,
            explanation: buildStructuredExplanation({
                classification: '⚠️ Invalid Input',
                isInvalidInput: true
            })
        };
    }

    const lowerText = text.toLowerCase();
    const indicators = [];
    let score = 0;

    // --- Step 2: Detect Content Type ---
    const contentType = detectContentType(text);
    const contentTypeLabels = {
        job: '📋 Job Posting',
        email: '📧 Email',
        message: '💬 Message / SMS',
        unknown: '📄 Unknown Content'
    };

    // --- Step 3: Run all pattern checks ---

    // Urgent language (10 pts each)
    const urgentMatches = scamPatterns.urgentLanguage.filter(p => lowerText.includes(p));
    if (urgentMatches.length > 0) {
        indicators.push(`⏰ Urgent/threatening language: ${urgentMatches.slice(0, 4).join(', ')}`);
        score += urgentMatches.length * 10;
    }

    // Money / fee requests (20 pts each)
    const moneyMatches = scamPatterns.moneyRequests.filter(p => lowerText.includes(p));
    if (moneyMatches.length > 0) {
        indicators.push(`💸 Requests for money / fees: ${moneyMatches.slice(0, 4).join(', ')}`);
        score += moneyMatches.length * 20;
    }

    // Personal data requests (25 pts each)
    const dataMatches = scamPatterns.personalData.filter(p => lowerText.includes(p));
    if (dataMatches.length > 0) {
        indicators.push(`🔐 Requests sensitive data / OTP / credentials: ${dataMatches.slice(0, 4).join(', ')}`);
        score += dataMatches.length * 25;
    }

    // Fake job phrases (15 pts each)
    const fakeJobMatches = scamPatterns.fakeJobPhrases.filter(p => lowerText.includes(p));
    if (fakeJobMatches.length > 0) {
        indicators.push(`🎭 Common fake job phrases: ${fakeJobMatches.slice(0, 4).join(', ')}`);
        score += fakeJobMatches.length * 15;
    }

    // Scam email phrases (18 pts each)
    const emailScamMatches = scamPatterns.emailScamPhrases.filter(p => lowerText.includes(p.toLowerCase()));
    if (emailScamMatches.length > 0) {
        indicators.push(`📩 Scam email patterns: ${emailScamMatches.slice(0, 4).join(', ')}`);
        score += emailScamMatches.length * 18;
    }

    // Scam SMS/message phrases (18 pts each)
    const msgScamMatches = scamPatterns.messageScamPhrases.filter(p => lowerText.includes(p.toLowerCase()));
    if (msgScamMatches.length > 0) {
        indicators.push(`📱 Scam message patterns: ${msgScamMatches.slice(0, 4).join(', ')}`);
        score += msgScamMatches.length * 18;
    }

    // Investment scam phrases (22 pts each)
    const investMatches = scamPatterns.investmentScamPhrases.filter(p => lowerText.includes(p.toLowerCase()));
    if (investMatches.length > 0) {
        indicators.push(`📈 Investment/financial scam indicators: ${investMatches.slice(0, 4).join(', ')}`);
        score += investMatches.length * 22;
    }

    // Romance/social engineering (20 pts each)
    const romanceMatches = scamPatterns.romanceScamPhrases.filter(p => lowerText.includes(p.toLowerCase()));
    if (romanceMatches.length > 0) {
        indicators.push(`❤️ Romance/social engineering patterns: ${romanceMatches.slice(0, 3).join(', ')}`);
        score += romanceMatches.length * 20;
    }

    // Lottery scam phrases (20 pts each)
    const lotteryMatches = scamPatterns.lotteryScamPhrases.filter(p => lowerText.includes(p.toLowerCase()));
    if (lotteryMatches.length > 0) {
        indicators.push(`🎰 Lottery/prize scam patterns: ${lotteryMatches.slice(0, 4).join(', ')}`);
        score += lotteryMatches.length * 20;
    }

    // Indian-specific scams (22 pts each)
    const indianMatches = scamPatterns.indianScamPhrases.filter(p => lowerText.includes(p.toLowerCase()));
    if (indianMatches.length > 0) {
        indicators.push(`🇮🇳 Indian-specific fraud patterns: ${indianMatches.slice(0, 4).join(', ')}`);
        score += indianMatches.length * 22;
    }

    // Suspicious contact methods (15 pts each)
    const contactMatches = scamPatterns.suspiciousContact.filter(p => lowerText.includes(p.toLowerCase()));
    if (contactMatches.length > 0) {
        indicators.push(`📞 Suspicious contact methods: ${contactMatches.slice(0, 3).join(', ')}`);
        score += contactMatches.length * 15;
    }

    // Unrealistic job offers (15 pts each)
    const unrealMatches = scamPatterns.unrealisticOffers.filter(p => lowerText.includes(p.toLowerCase()));
    if (unrealMatches.length > 0) {
        indicators.push(`🚀 Unrealistic/exaggerated earnings claimed: ${unrealMatches.slice(0, 3).join(', ')}`);
        score += unrealMatches.length * 15;
    }

    // Free email domains used in body (30 pts flat)
    const emailRegex = /([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9._-]+)/gi;
    const emailsFound = text.match(emailRegex) || [];
    const freeEmailMatches = emailsFound.filter(e => {
        const domain = e.split('@')[1]?.toLowerCase();
        return domain && scamPatterns.freeDomains.includes(domain);
    });
    if (freeEmailMatches.length > 0) {
        indicators.push(`📧 Free/unprofessional email domains used: ${freeEmailMatches.slice(0, 3).join(', ')}`);
        score += 30;
    }

    // --- Step 4: Boost score for certain high-risk content type combos ---
    // If content type is message AND has OTP phrases — very high risk
    if (contentType === 'message' && (lowerText.includes('otp') || lowerText.includes('mpin') || lowerText.includes('upi pin'))) {
        score += 40;
        if (!indicators.some(i => i.includes('OTP'))) {
            indicators.push('🚨 OTP/PIN phishing detected in message context — extremely high risk');
        }
    }

    // If content type is email AND has lottery/prize signals — very high risk
    if (contentType === 'email' && lotteryMatches.length > 0) {
        score += 20;
    }

    // --- Step 5: Extract auxiliary info ---
    let companyName = 'Unknown';
    const companyMatch = text.match(/(?:at|for|from|by|company[:\s]+)\s+([A-Z][a-zA-Z]+(?:\s+[A-Z][a-zA-Z]+){0,3})/);
    if (companyMatch) companyName = companyMatch[1].trim();

    const urlRegex = /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&/=]*)/gi;
    const links = text.match(urlRegex) || [];
    const appLink = links.length > 0 ? links[0] : 'Official Portal';

    // Suspicious short URLs (bit.ly, tinyurl, etc.) add points
    const shortUrlDomains = ['bit.ly', 'tinyurl', 'goo.gl', 'ow.ly', 't.co', 'rb.gy', 'cutt.ly', 'short.ly', 'tiny.cc'];
    const matchedShortUrls = links.filter(l => shortUrlDomains.some(s => l.includes(s)));
    const hasShortUrl = matchedShortUrls.length > 0;
    if (hasShortUrl) {
        indicators.push('🔗 Shortened/obfuscated URL detected — potential phishing link');
        score += 25;
    }

    // --- Step 6: Classify ---
    let classification;
    if (score >= 60) {
        if (contentType === 'email') classification = '❌ Scam Mail';
        else if (contentType === 'message') classification = '❌ Scam Message';
        else classification = '❌ Fake Job / Scam';
    } else if (score >= 20) {
        if (contentType === 'email') classification = '⚠️ Suspicious Email';
        else if (contentType === 'message') classification = '⚠️ Suspicious Message';
        else classification = '⚠️ Suspicious Job Post';
    } else {
        if (contentType === 'job') classification = '✅ Genuine Job';
        else if (contentType === 'email') classification = '✅ Legitimate Email';
        else if (contentType === 'message') classification = '✅ Legitimate Message';
        else classification = '⚠️ Unrecognized Content';
    }

    // Normalize confidence score to 0–100
    const confidenceScore = Math.min(score, 100);

    // --- Step 7: Build Structured Explanation ---
    const explanation = buildStructuredExplanation({
        classification,
        isInvalidInput: false,
        urgentMatches,
        moneyMatches,
        dataMatches,
        fakeJobMatches,
        emailScamMatches,
        msgScamMatches,
        investMatches,
        romanceMatches,
        lotteryMatches,
        indianMatches,
        contactMatches,
        unrealMatches,
        freeEmailMatches,
        matchedShortUrls
    });

    return {
        classification,
        contentType,
        contentTypeLabel: contentTypeLabels[contentType],
        indicators,
        confidenceScore,
        companyName,
        appLink,
        extractedText: text,
        isInvalidInput: false,
        explanation
    };
};

module.exports = { analyzeScamContent, buildStructuredExplanation };
