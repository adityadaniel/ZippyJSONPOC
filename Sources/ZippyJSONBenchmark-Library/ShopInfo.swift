import Foundation

public struct HeaderAndShopInfoData: Decodable, Equatable {
    public var header: ShopHeaderLayout?
    public var info: ShopInfoResponseGQL
    public let reputation: ShopReputation?
    public let shopOperationalHours: ShopOperationalHours?
    public let feed: ShopFeedResponse?
    public var homeInfoData: ShopHomeInfoData?
    public let dynamicTabInfoData: ShopDynamicTabInfoData?

    private enum CodingKeys: String, CodingKey {
        case header = "ShopPageGetHeaderLayout"
        case info = "shopInfoByID"
        case reputation = "reputation_shops"
        case shopOperationalHours = "getShopOperationalHourStatus"
        case feed = "feedv2"
        case homeInfoData = "shopPageGetHomeType"
        case dynamicTabInfoData = "shopPageGetDynamicTab"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        header = try container.decodeIfPresent(ShopHeaderLayout.self, forKey: .header)
        info = try container.decode(ShopInfoResponseGQL.self, forKey: .info)
        let reputations = try container.decodeIfPresent([ShopReputation].self, forKey: .reputation)
        reputation = reputations?.first
        shopOperationalHours = try container.decodeIfPresent(ShopOperationalHours.self, forKey: .shopOperationalHours)
        feed = try container.decodeIfPresent(ShopFeedResponse.self, forKey: .feed)
        homeInfoData = try container.decodeIfPresent(ShopHomeInfoData.self, forKey: .homeInfoData)
        dynamicTabInfoData = try container.decodeIfPresent(ShopDynamicTabInfoData.self, forKey: .dynamicTabInfoData)
    }

    public init(header: ShopHeaderLayout?, info: ShopInfoResponseGQL, reputation: ShopReputation?, shopOperationalHours: ShopOperationalHours?, feed: ShopFeedResponse?, homeInfoData: ShopHomeInfoData?, dynamicTabInfoData: ShopDynamicTabInfoData?) {
        self.header = header
        self.info = info
        self.reputation = reputation
        self.shopOperationalHours = shopOperationalHours
        self.feed = feed
        self.homeInfoData = homeInfoData
        self.dynamicTabInfoData = dynamicTabInfoData
    }
}

public struct ShopDynamicTabInfoData: Decodable, Equatable {
    public let tabData: [ShopTabData]
}

public enum ShopTabName: String, Equatable {
    case home = "hometab"
    case campaign = "campaigntab"
    case product = "producttab"
    case etalase = "etalasetab"
    case feed = "feedtab"
    case review = "reviewtab"
    case unknown
}

public struct ShopTabData: Decodable, Equatable {
    public let tabName: ShopTabName
    public let tabTitle: String
    public let isActive: Bool
    public let isFocus: Bool
    public var errorMessage: String?
    public let isDefault: Bool
    public let shopLayoutFeatures: [ShopLayoutFeatures]
    public let iconUrl: DynamicTabIcon
    public let iconUrlSelected: DynamicTabIcon

    /// - - - Tab type
    /// `logic`: for tab that need development / BE logic
    /// `config`: for tab that doesn’t need development / the logic is from FE
    public let type: String
    public let data: ShopPageTabData
    public let backgroundColors: [String]
    public let textColor: String
    public let backgroundImage: String?
    public let lottieAnimationURL: URL?

    private enum CodingKeys: String, CodingKey {
        case tabName = "name"
        case tabTitle = "text"
        case iconUrl = "icon"
        case iconUrlSelected = "iconFocus"
        case backgroundColors = "bgColors"
        case lottieAnimationURL = "imgLottie"
        case isActive, isFocus, errorMessage, isDefault, type, data, shopLayoutFeatures, textColor, bgImage
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tabNameString = try container.decode(String.self, forKey: .tabName)
        tabName = ShopTabName(rawValue: tabNameString.lowercased()) ?? .unknown
        switch tabName {
        case .home:
            let hometabData = try container.decode(ShopHomeLayoutResponse.self, forKey: .data)
            data = .homeTabData(hometabData)
        case .campaign:
            let campaignTabData = try container.decode(ShopCampaignTabLayoutResponse.self, forKey: .data)
            data = .campaignTabData(campaignTabData)
        default: data = .unknown
        }
        tabTitle = try container.decode(String.self, forKey: .tabTitle)
        let isActiveInt = try container.decode(Int.self, forKey: .isActive)
        isActive = try isActiveInt.convert(to: Bool.self)
        let isFocusInt = try container.decode(Int.self, forKey: .isFocus)
        isFocus = try isFocusInt.convert(to: Bool.self)
        errorMessage = try container.decode(String.self, forKey: .errorMessage)
        isDefault = try container.decode(Bool.self, forKey: .isDefault)
        let iconString = try container.decode(String.self, forKey: .iconUrl)
        let iconJSONData = Data(iconString.utf8)
        iconUrl = try JSONDecoder().decode(DynamicTabIcon.self, from: iconJSONData)
        let iconSelectedString = try container.decode(String.self, forKey: .iconUrlSelected)
        let iconSelectedJSONData = Data(iconSelectedString.utf8)
        iconUrlSelected = try JSONDecoder().decode(DynamicTabIcon.self, from: iconSelectedJSONData)
        type = try container.decode(String.self, forKey: .type)
        shopLayoutFeatures = try container.decodeIfPresent([ShopLayoutFeatures].self, forKey: .shopLayoutFeatures) ?? []
        backgroundColors = try container.decode([String].self, forKey: .backgroundColors)
        textColor = try container.decode(String.self, forKey: .textColor)
        backgroundImage = try container.decodeIfPresent(String.self, forKey: .bgImage) ?? ""
        let lottieURLString = try container.decodeIfPresent(String.self, forKey: .lottieAnimationURL) ?? ""
        lottieAnimationURL = URL(string: lottieURLString)
    }

    public init(
        tabName: ShopTabName,
        tabTitle: String,
        isActive: Bool,
        isFocus: Bool,
        isDefault: Bool,
        iconUrl: DynamicTabIcon,
        iconUrlSelected: DynamicTabIcon,
        type: String,
        data: ShopPageTabData,
        backgroundColors: [String],
        textColor: String,
        shopLayoutFeatures: [ShopLayoutFeatures],
        backgroundImage: String?,
        lottieAnimationURL: URL?
    ) {
        self.tabName = tabName
        self.tabTitle = tabTitle
        self.isActive = isActive
        self.isFocus = isFocus
        self.isDefault = isDefault
        self.iconUrl = iconUrl
        self.iconUrlSelected = iconUrlSelected
        self.type = type
        self.data = data
        self.backgroundColors = backgroundColors
        self.textColor = textColor
        self.shopLayoutFeatures = shopLayoutFeatures
        self.backgroundImage = backgroundImage
        self.lottieAnimationURL = lottieAnimationURL
    }
}

public enum ShopPageTabData: Decodable, Equatable {
    case homeTabData(ShopHomeLayoutResponse)
    case campaignTabData(ShopCampaignTabLayoutResponse)
    case unknown
}

public struct ShopCampaignTabLayoutResponse: Decodable, Equatable {
    public let widgetIDList: [WidgetRequestParameter]

    public var containsMVCWidget: Bool {
        widgetIDList.contains(where: { $0.widgetType == .voucher })
    }
}

public struct WidgetRequestParameter: Equatable, Hashable {
    public let widgetId: Int
    public let widgetMasterId: Int
    public let widgetType: HomeTabWidgetType
    public let widgetName: HomeTabWidgetName
    public var widgetHeader: HomeTabWidgetHeader?
    public var isRequested: Bool = false
    public var isFestivity: Bool

    public init(
        widgetId: Int,
        widgetMasterId: Int,
        widgetType: HomeTabWidgetType,
        widgetName: HomeTabWidgetName,
        widgetHeader: HomeTabWidgetHeader? = nil,
        isRequested: Bool = false,
        isFestivity: Bool = false
    ) {
        self.widgetId = widgetId
        self.widgetMasterId = widgetMasterId
        self.widgetType = widgetType
        self.widgetName = widgetName
        self.widgetHeader = widgetHeader
        self.isRequested = isRequested
        self.isFestivity = isFestivity
    }
}

public enum HomeTabWidgetType: String, Equatable, Decodable {
    case display
    case product
    case voucher = "promo"
    case campaign
    case dynamic
    case perso
    case etalase
    case bundle
    case unknown
    case card
}

public enum HomeTabWidgetName: String, Equatable, Decodable {
    case sliderBanner = "slider_banner"
    case sliderSquare = "slider_square"
    case displaySingleColumn = "display_single_column"
    case displayDoubleColumn = "display_double_column"
    case displayTripleColumn = "display_triple_column"
    case video
    case product
    case promoCampaign = "promo_campaign"
    case flashSaleToko = "flash_sale_toko"
    case bigCampaignThematic = "big_campaign_thematic"
    case etalaseThematic = "etalase_thematic"
    case play
    case voucher
    case voucherStatic = "voucher_static"
    case buyAgain = "buy_again"
    case recentActivity = "recent_activity"
    case reminder
    case addOn = "add_ons"
    case trending
    case stacked2x1Showcase = "etalase_banner_besar_2x1"
    case stacked2x2Showcase = "etalase_banner_besar_2x2"
    case stacked3x2Showcase = "etalase_banner_3_x_2"
    case smallSliderShowcase = "etalase_slider_kecil"
    case mediumSliderShowcase = "etalase_slider_medium"
    case smallSliderTwoRow = "etalase_slider_kecil_2_baris"
    case singleBundling = "single_bundling"
    case multipleBundling = "multiple_bundling"
    case unknown
    case infoCard = "info_card"
}

public struct HomeTabWidgetHeader: Equatable, Hashable, Decodable {
    public struct Data: Equatable, Hashable, Decodable {
        public let linkType: String
        public let linkID: Int

        public init(linkType: String, linkID: Int) {
            self.linkType = linkType
            self.linkID = linkID
        }
    }

    public let title: String
    public let data: [Data]

    public init(title: String, data: [Data]) {
        self.title = title
        self.data = data
    }

    private enum CodingKeys: String, CodingKey {
        case title, data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        data = try container.decodeIfPresent([HomeTabWidgetHeader.Data].self, forKey: .data) ?? []
    }
}


extension WidgetRequestParameter: Decodable {
    private enum CodingKeys: String, CodingKey {
        case widgetId = "widgetID"
        case widgetMasterId = "widgetMasterID"
        case widgetType
        case widgetHeader = "header"
        case widgetName
        case isFestivity
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        widgetId = try container.decode(Int.self, forKey: .widgetId)
        widgetMasterId = try container.decode(Int.self, forKey: .widgetMasterId)
        let widgetTypeString = try container.decode(String.self, forKey: .widgetType)
        widgetType = HomeTabWidgetType(rawValue: widgetTypeString) ?? .unknown
        let widgetNameString = try container.decode(String.self, forKey: .widgetName)
        widgetName = HomeTabWidgetName(rawValue: widgetNameString) ?? .unknown
        widgetHeader = try container.decodeIfPresent(HomeTabWidgetHeader.self, forKey: .widgetHeader)
        isFestivity = try container.decodeIfPresent(Bool.self, forKey: .isFestivity) ?? false
    }

    public var identifier: String {
        "\(widgetId)"
    }
}

public struct ShopHomeLayoutData {
    public let layoutId: Int
    public let masterLayoutId: Int
    public let widgetIdList: [WidgetRequestParameter]

    public var containsMVCWidget: Bool {
        widgetIdList.contains(where: { $0.widgetType == .voucher })
    }
}

extension ShopHomeLayoutData: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case layoutId = "layoutID"
        case masterLayoutId = "masterLayoutID"
        case widgetIdList = "widgetIDList"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        layoutId = try container.decode(Int.self, forKey: .layoutId)
        masterLayoutId = try container.decode(Int.self, forKey: .masterLayoutId)
        widgetIdList = try container.decode([WidgetRequestParameter].self, forKey: .widgetIdList)
    }
}

public struct ShopHomeLayoutResponse: Decodable, Equatable {
    public let homeLayoutData: ShopHomeLayoutData
}

public struct DynamicTabIcon: Decodable, Equatable {
    public init(darkMode: String?, lightMode: String?) {
        self.darkMode = darkMode
        self.lightMode = lightMode
    }

    public let darkMode: String?
    public let lightMode: String?

    private enum CodingKeys: String, CodingKey {
        case darkMode = "dark_mode"
        case lightMode = "light_mode"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        darkMode = try? container.decodeIfPresent(String.self, forKey: .darkMode) ?? ""
        lightMode = try? container.decodeIfPresent(String.self, forKey: .lightMode) ?? ""
    }
}


public struct ShopHomeInfoData: Decodable, Equatable {
    public let homeType: ShopHomeType
    public let homeLayoutData: ShopHomeLayoutData
    public var shopLayoutFeatures: [ShopLayoutFeatures]

    private enum CodingKeys: String, CodingKey {
        case homeType = "shopHomeType"
        case homeLayoutData
        case shopLayoutFeatures
    }

    internal init(homeType: ShopHomeType, homeLayoutData: ShopHomeLayoutData, shopLayoutFeatures: [ShopLayoutFeatures]) {
        self.homeType = homeType
        self.homeLayoutData = homeLayoutData
        self.shopLayoutFeatures = shopLayoutFeatures
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let rawHomeType = try container.decode(String.self, forKey: .homeType)
        homeType = ShopHomeType(rawValue: rawHomeType) ?? .none
        homeLayoutData = try container.decode(ShopHomeLayoutData.self, forKey: .homeLayoutData)
        shopLayoutFeatures = try container.decodeIfPresent([ShopLayoutFeatures].self, forKey: .shopLayoutFeatures) ?? []
    }
}

public struct ShopLayoutFeatures {
    public let name: String
    public let isActive: Bool

    public init(name: String, isActive: Bool) {
        self.name = name
        self.isActive = isActive
    }
}

extension ShopLayoutFeatures: Decodable, Equatable {}

public struct ShopFeedResponse: Decodable, Equatable {
    public let hasItems: Bool

    public init(hasItems: Bool) {
        self.hasItems = hasItems
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode([FeedData].self, forKey: .data)

        hasItems = !data.isEmpty
    }

    private enum CodingKeys: String, CodingKey {
        case data
    }

    private struct FeedData: Equatable, Decodable {
        internal let id: Int
    }
}

public struct ShopOperationalHours: Decodable, Equatable {
    public let statusActive: Bool
    // get from error -> field message
    public let errorMessage: String
    public let tickerTitle: String
    public let tickerMessage: String
    public let startTime: String
    public let endTime: String

    private enum CodingKeys: String, CodingKey {
        case statusActive
        case error
        case errorMessage = "message"
        case tickerTitle
        case tickerMessage
        case startTime
        case endTime
    }

    public init(statusActive: Bool, errorMessage: String, tickerTitle: String, tickerMessage: String, startTime: String, endTime: String) {
        self.statusActive = statusActive
        self.errorMessage = errorMessage
        self.tickerTitle = tickerTitle
        self.tickerMessage = tickerMessage
        self.startTime = startTime
        self.endTime = endTime
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusActive = try container.decode(Bool.self, forKey: .statusActive)
        let message = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .error)
        errorMessage = try message.decode(String.self, forKey: .errorMessage)
        tickerTitle = try container.decode(String.self, forKey: .tickerTitle)
        tickerMessage = try container.decode(String.self, forKey: .tickerMessage)
        startTime = try container.decode(String.self, forKey: .startTime)
        endTime = try container.decode(String.self, forKey: .endTime)
    }
}


public struct ShopReputation: Decodable, Equatable {
    public let badge: URL?
    public let badgeHD: URL?
    public let score: String

    public init(badge: URL?, badgeHD: URL?, score: String) {
        self.badge = badge
        self.badgeHD = badgeHD
        self.score = score
    }

    enum CodingKeys: String, CodingKey {
        case badge, score
        case badgeHD = "badge_hd"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let badgeUrl = try values.decode(String.self, forKey: .badge)
        badge = URL(string: badgeUrl)

        let badgeHDUrl = try values.decode(String.self, forKey: .badgeHD)
        badgeHD = URL(string: badgeHDUrl)

        score = try values.decode(String.self, forKey: .score)
    }
}


public struct ShopHeaderLayout {
    public let widgets: [ShopHeaderWidget]

    public init(widgets: [ShopHeaderWidget]) {
        self.widgets = widgets
    }
}

extension ShopHeaderLayout: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case widgets
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        widgets = try container.decode([ShopHeaderWidget].self, forKey: .widgets)
    }
}

public enum ShopHeaderWidgetType: String {
    case shopBasicInfo = "shop_basic_info"
    case shopPerformance = "shop_performance"
    case actionButton = "action_button"
    case unknown

    public var trackerName: String {
        switch self {
        case .shopBasicInfo: return "basic info"
        case .shopPerformance: return "performance"
        case .actionButton: return "action"
        case .unknown: return ""
        }
    }
}

extension ShopHeaderWidgetType: Decodable, Equatable {}

public struct ShopHeaderWidget {
    public let widgetId: Int
    public let name: String
    public let type: ShopHeaderWidgetType
    public let component: [HeaderComponent]

    public init(widgetId: Int, name: String, type: ShopHeaderWidgetType, component: [HeaderComponent]) {
        self.widgetId = widgetId
        self.name = name
        self.type = type
        self.component = component
    }
}

extension ShopHeaderWidget: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case widgetId = "widgetID"
        case name, type, component
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        widgetId = try container.decode(Int.self, forKey: .widgetId)
        name = try container.decode(String.self, forKey: .name)
        let typeString = try container.decode(String.self, forKey: .type)
        type = ShopHeaderWidgetType(rawValue: typeString) ?? .unknown
        component = try container.decode([HeaderComponent].self, forKey: .component)
    }
}

public enum HeaderComponentType: String, Decodable, Equatable {
    case shopLogo = "shop_logo"
    case shopName = "shop_name"
    case shopRating = "shop_rating"
    case shopHandling = "shop_handling"
    case shopOperationalHour = "shop_operational_hour"
    case shopTotalFollower = "shop_total_follower"
    case bebasOngkir = "bebas_ongkir"
    case shopTotalProduct = "shop_total_product"
    case shopChatReplySpeed = "shop_chat_reply_speed"
    case shopSoldProduct = "shop_sold_product"
    case shopNotes = "shop_notes"
    case chat
    case followMember = "follow_member"
    case reputation
    case unknown
}

public struct HeaderWidgetCommonData {
    public let name: String
    public let componentType: HeaderComponentType
    public let type: HeaderWidgetType

    public init(name: String, componentType: HeaderComponentType, type: HeaderWidgetType) {
        self.name = name
        self.type = type
        self.componentType = componentType
    }
}

extension HeaderWidgetCommonData: Decodable, Equatable {}

public enum HeaderComponent {
    case imageOnly(commonData: HeaderWidgetCommonData, specificData: HeaderImageData)
    case badgeText(commonData: HeaderWidgetCommonData, specificData: HeaderBadgeTextData)
    case button(commonData: HeaderWidgetCommonData, specificData: HeaderButtonData)
    case imageText(commonData: HeaderWidgetCommonData, specificData: HeaderImageTextData)
    case unknown
}

extension HeaderComponent {
    public var nameString: String {
        switch self {
        case .imageOnly(commonData: let commonData, specificData: _):
            return commonData.name
        case .badgeText(commonData: let commonData, specificData: _):
            return commonData.name
        case .button(commonData: let commonData, specificData: _):
            return commonData.name
        case .imageText(commonData: let commonData, specificData: _):
            return commonData.name
        case .unknown:
            return ""
        }
    }

    public var type: HeaderComponentType {
        switch self {
        case .imageOnly(commonData: let commonData, specificData: _):
            return commonData.componentType
        case .badgeText(commonData: let commonData, specificData: _):
            return commonData.componentType
        case .button(commonData: let commonData, specificData: _):
            return commonData.componentType
        case .imageText(commonData: let commonData, specificData: _):
            return commonData.componentType
        case .unknown:
            return .unknown
        }
    }
}

extension HeaderComponent: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case name, type, data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let componentType = HeaderComponentType(rawValue: name) ?? .unknown
        let typeString = try container.decode(String.self, forKey: .type)
        let type = HeaderWidgetType(rawValue: typeString) ?? .unknown
        let commonData = HeaderWidgetCommonData(name: name, componentType: componentType, type: type)

        switch type {
        case .imageOnly:
            let data = try container.decode(HeaderImageData.self, forKey: .data)
            self = .imageOnly(commonData: commonData, specificData: data)
        case .badgeTextValue:
            let data = try container.decode(HeaderBadgeTextData.self, forKey: .data)
            self = .badgeText(commonData: commonData, specificData: data)
        case .button:
            let data = try container.decode(HeaderButtonData.self, forKey: .data)
            self = .button(commonData: commonData, specificData: data)
        case .imageText:
            let data = try container.decode(HeaderImageTextData.self, forKey: .data)
            self = .imageText(commonData: commonData, specificData: data)
        case .unknown:
            self = .unknown
        }
    }
}

public enum HeaderWidgetType: String, Decodable, Equatable {
    case imageOnly = "image_only"
    case badgeTextValue = "badge_text_value"
    case imageText = "image_text"
    case button
    case unknown
}

public struct HeaderImageData {
    public let image: String
    public let imageLink: String
    public let isBottomSheet: Bool

    public init(image: String, imageLink: String, isBottomSheet: Bool) {
        self.image = image
        self.imageLink = imageLink
        self.isBottomSheet = isBottomSheet
    }
}

extension HeaderImageData: Decodable, Equatable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        image = try container.decode(String.self, forKey: .image)
        imageLink = try container.decode(String.self, forKey: .imageLink)
        isBottomSheet = try container.decode(Bool.self, forKey: .isBottomSheet)
    }

    public enum CodingKeys: String, CodingKey {
        case image, imageLink, isBottomSheet
    }
}

public struct HeaderBadgeTextData {
    public let ctaText: String
    public let ctaLink: String
    public let ctaIcon: String
    public let text: [BadgeTextData]

    public init(ctaText: String, ctaLink: String, ctaIcon: String, text: [BadgeTextData]) {
        self.ctaText = ctaText
        self.ctaLink = ctaLink
        self.ctaIcon = ctaIcon
        self.text = text
    }
}

extension HeaderBadgeTextData: Decodable, Equatable {
    public enum CodingKeys: String, CodingKey {
        case ctaText, ctaLink, ctaIcon, text
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ctaText = try container.decode(String.self, forKey: .ctaText)
        ctaLink = try container.decode(String.self, forKey: .ctaLink)
        ctaIcon = try container.decode(String.self, forKey: .ctaIcon)
        text = try container.decode([BadgeTextData].self, forKey: .text)
    }
}

public struct BadgeTextData {
    public let icon: String
    public let textLink: String
    public var textHtml: String
    public let isBottomSheet: Bool

    public init(icon: String, textLink: String, textHtml: String, isBottomSheet: Bool) {
        self.icon = icon
        self.textLink = textLink
        self.textHtml = textHtml
        self.isBottomSheet = isBottomSheet
    }
}

extension BadgeTextData: Decodable, Equatable {
    public enum CodingKeys: String, CodingKey {
        case icon, textLink, textHtml, isBottomSheet
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        icon = try container.decode(String.self, forKey: .icon)
        textLink = try container.decode(String.self, forKey: .textLink)
        textHtml = try container.decode(String.self, forKey: .textHtml)
        isBottomSheet = try container.decode(Bool.self, forKey: .isBottomSheet)
    }
}

public struct HeaderButtonData {
    public let icon: String
    public let buttonType: String
    public let link: String
    public let isBottomSheet: Bool
    public let label: String

    public init(icon: String, buttonType: String, link: String, isBottomSheet: Bool, label: String) {
        self.icon = icon
        self.buttonType = buttonType
        self.link = link
        self.isBottomSheet = isBottomSheet
        self.label = label
    }
}

extension HeaderButtonData: Decodable, Equatable {
    public enum CodingKeys: String, CodingKey {
        case icon, buttonType, link, isBottomSheet, label
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        icon = try container.decode(String.self, forKey: .icon)
        buttonType = try container.decode(String.self, forKey: .buttonType)
        link = try container.decode(String.self, forKey: .link)
        isBottomSheet = try container.decode(Bool.self, forKey: .isBottomSheet)
        label = try container.decode(String.self, forKey: .label)
    }
}

public struct HeaderImageTextData {
    public let images: HeaderImageComponent
    public let textComponent: HeaderTextComponent
}

extension HeaderImageTextData: Decodable, Equatable {}

public struct HeaderImageComponent {
    public let style: Int
    public let data: [HeaderImageComponentData]
}

extension HeaderImageComponent: Decodable, Equatable {}

public struct HeaderImageComponentData {
    public let image: String
    public let imageLink: String
    public let isBottomSheet: Bool
}

extension HeaderImageComponentData: Decodable, Equatable {}

public struct HeaderTextComponent {
    public let style: Int
    public let data: HeaderTextComponentData
}

extension HeaderTextComponent: Decodable, Equatable {}

public struct HeaderTextComponentData {
    public let icon: String
    public let textLink: String
    public let textHtml: String
    public let isBottomSheet: Bool
}

extension HeaderTextComponentData: Decodable, Equatable {}


public struct ShopInfoResponseGQL: Decodable, Equatable {
    public var result: TokoShopInfoData?
    public let error: ShopInfoGQLError

    public init(result: TokoShopInfoData?, error: ShopInfoGQLError) {
        self.result = result
        self.error = error
    }

    private enum CodingKeys: String, CodingKey {
        case result, error
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let results = try container.decode([TokoShopInfoData].self, forKey: .result)
        result = results.first
        error = try container.decode(ShopInfoGQLError.self, forKey: .error)
    }
}

public struct ShopInfoGQLError: Decodable, Equatable {
    public let message: String

    public init(message: String) {
        self.message = message
    }
}

public struct TokoShopInfoData: Equatable {
    public let shopHomeType: ShopHomeType?
    public let closedInfo: ClosedInfoData?
    public let isOpen: Bool
    public let ownerInfo: OwnerData?
    public let shopLastActive: String?
    public let shipmentInfo: [ShopShipmentData]?
    public let favoriteData: FavoriteData?
    public let createInfo: CreateData?
    public let shopAssets: ImageData?
    public let shopCore: ShopCoreData?
    public let location: String?
    public var statusInfo: StatusData?
    public let isOwner: Bool
    public let isAllowManage: Bool
    public let goldOS: GoldOSData?
    public let shopStatus: StatsData?
    public let blackBoxInfo: [BlackBoxData]?
    public let topContent: ShopTopContent?
    public let freeShipping: ShopFreeShipping?
    public let activeProductCount: Int?
    public let shopSnippetUrl: String
    public let branchLinkDomain: String?
    public var isGoApotik: Bool
    public var ePharmacyInfo: ShopEPharmacyInfo?
    public var partnerInfo: [PartnerInfoData]?

    /// For GoApotik section in Shop Info, this logic is for showing `SIA, SIPA, APJ` value
    /// We read from 2 properties, `fsType == .ePharmacy` OR `isGoApotik`
    public var showEpharmacyInfo: Bool {
        (partnerInfo?.contains(where: { $0.fsType == .ePharmacy }) ?? false) || isGoApotik
    }

    public init(closedInfo: ClosedInfoData?, isOpen: Bool, ownerInfo: OwnerData?, shopLastActive: String?, shipmentInfo: [ShopShipmentData]?, favoriteData: FavoriteData?, createInfo: CreateData?, shopAssets: ImageData?, shopCore: ShopCoreData?, location: String?, statusInfo: StatusData?, isOwner: Bool, isAllowManage: Bool, goldOS: GoldOSData?, shopStatus: StatsData?, blackBoxInfo: [BlackBoxData]?, topContent: ShopTopContent?, freeShipping: ShopFreeShipping?, shopHomeType: ShopHomeType?, activeProductCount: Int?, shopSnippetUrl: String, branchLinkDomain: String?, isGoApotik: Bool, ePharmacyInfo: ShopEPharmacyInfo?, partnerInfo: [PartnerInfoData]?) {
        self.closedInfo = closedInfo
        self.isOpen = isOpen
        self.ownerInfo = ownerInfo
        self.shopLastActive = shopLastActive
        self.shipmentInfo = shipmentInfo
        self.favoriteData = favoriteData
        self.createInfo = createInfo
        self.shopAssets = shopAssets
        self.shopCore = shopCore
        self.location = location
        self.statusInfo = statusInfo
        self.isOwner = isOwner
        self.isAllowManage = isAllowManage
        self.goldOS = goldOS
        self.shopStatus = shopStatus
        self.blackBoxInfo = blackBoxInfo
        self.topContent = topContent
        self.freeShipping = freeShipping
        self.shopHomeType = shopHomeType
        self.activeProductCount = activeProductCount
        self.shopSnippetUrl = shopSnippetUrl
        self.branchLinkDomain = branchLinkDomain
        self.isGoApotik = isGoApotik
        self.ePharmacyInfo = ePharmacyInfo
        self.partnerInfo = partnerInfo
    }
}

extension TokoShopInfoData: Decodable {
    private enum CodingKeys: String, CodingKey {
        case address, closedInfo, isOpen, ownerInfo, shopLastActive, shipmentInfo, favoriteData, createInfo,
            shopAssets, shopCore, location, statusInfo, isOwner, goldOS, topContent, shopHomeType, isAllowManage, branchLinkDomain, isGoApotik, partnerInfo
        case shopStatus = "shopStats"
        case blackBoxInfo = "bbInfo"
        case freeShipping = "freeOngkir"
        case activeProductCount = "activeProduct"
        case shopSnippetUrl = "shopSnippetURL"
        case ePharmacyInfo = "epharmacyInfo"
    }

    /// is shop owner or admin with manage shop permission
    public var isOwnerOrAdmin: Bool {
        isOwner || isAllowManage
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        closedInfo = try container.decodeIfPresent(ClosedInfoData.self, forKey: .closedInfo)
        let isOpen = try container.decodeIfPresent(Int.self, forKey: .isOpen) ?? 0
        self.isOpen = isOpen == 1
        ownerInfo = try container.decodeIfPresent(OwnerData.self, forKey: .ownerInfo)
        shopLastActive = try container.decodeIfPresent(String.self, forKey: .shopLastActive)
        shipmentInfo = try container.decodeIfPresent([ShopShipmentData].self, forKey: .shipmentInfo)
        favoriteData = try container.decodeIfPresent(FavoriteData.self, forKey: .favoriteData)
        createInfo = try container.decodeIfPresent(CreateData.self, forKey: .createInfo)
        shopAssets = try container.decodeIfPresent(ImageData.self, forKey: .shopAssets)
        shopCore = try container.decodeIfPresent(ShopCoreData.self, forKey: .shopCore)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        statusInfo = try container.decodeIfPresent(StatusData.self, forKey: .statusInfo)
        let isOwner = try container.decodeIfPresent(Int.self, forKey: .isOwner) ?? 0
        self.isOwner = isOwner == 1
        let isAllowManage = try container.decodeIfPresent(Int.self, forKey: .isAllowManage) ?? 0
        self.isAllowManage = isAllowManage == 1

        goldOS = try container.decodeIfPresent(GoldOSData.self, forKey: .goldOS)
        shopStatus = try container.decodeIfPresent(StatsData.self, forKey: .shopStatus)
        blackBoxInfo = try container.decodeIfPresent([BlackBoxData].self, forKey: .blackBoxInfo)
        topContent = try container.decodeIfPresent(ShopTopContent.self, forKey: .topContent)
        freeShipping = try container.decodeIfPresent(ShopFreeShipping.self, forKey: .freeShipping)
        let shopHomeType = try container.decodeIfPresent(String.self, forKey: .shopHomeType)
        self.shopHomeType = ShopHomeType(rawValue: shopHomeType ?? "") ?? ShopHomeType.none
        activeProductCount = try container.decodeIfPresent(Int.self, forKey: .activeProductCount)
        shopSnippetUrl = try container.decodeIfPresent(String.self, forKey: .shopSnippetUrl) ?? ""
        branchLinkDomain = try container.decodeIfPresent(String.self, forKey: .branchLinkDomain) ?? ""
        isGoApotik = try container.decodeIfPresent(Bool.self, forKey: .isGoApotik) ?? false
        ePharmacyInfo = try container.decodeIfPresent(ShopEPharmacyInfo.self, forKey: .ePharmacyInfo)
        partnerInfo = try container.decodeIfPresent([PartnerInfoData].self, forKey: .partnerInfo)
    }
}

public enum ShopHomeType: String, Equatable {
    case native,
        webview,
        none

    public var defaultSelectedTabIndex: ShopPageStartingTab {
        switch self {
        case .native:
            return .home
        case .webview, .none: return .product
        }
    }
}


public enum ShopPageStartingTab: String {
    case home = "hometab"
    case campaign = "campaigntab"
    case product = "producttab"
    case update = "feedtab"
    case showcase = "etalasetab"
    case review = "reviewtab"
}


public struct ClosedInfoData: Equatable {
    public let closedNote: String
    public let reason: String
    public let until: String
    public let detail: CloseInfoDetailData?

    public init(closedNote: String, reason: String, until: String, detail: CloseInfoDetailData?) {
        self.closedNote = closedNote
        self.reason = reason
        self.until = until
        self.detail = detail
    }
}

extension ClosedInfoData: Decodable {
    private enum CodingKeys: String, CodingKey {
        case closedNote, reason, until, detail
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        closedNote = try container.decodeIfPresent(String.self, forKey: .closedNote) ?? ""
        reason = try container.decodeIfPresent(String.self, forKey: .reason) ?? ""
        until = try container.decodeIfPresent(String.self, forKey: .until) ?? ""
        detail = try container.decodeIfPresent(CloseInfoDetailData.self, forKey: .detail)
    }
}

public struct CloseInfoDetailData: Decodable, Equatable {
    public let openDateUTC: String

    private enum CodingKeys: String, CodingKey {
        case openDateUTC
    }

    public init(openDateUTC: String) {
        self.openDateUTC = openDateUTC
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        openDateUTC = try container.decodeIfPresent(String.self, forKey: .openDateUTC) ?? ""
    }
}

public struct OwnerData: Equatable {
    public let id: String
    public let email: String
    public let imageURL: URL?
    public let name: String
    public let status: Int?

    public init(id: String, email: String, imageURL: URL?, name: String, status: Int?) {
        self.id = id
        self.email = email
        self.imageURL = imageURL
        self.name = name
        self.status = status
    }
}

extension OwnerData: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id, email, imageURL, name, status
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        let imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL) ?? ""
        self.imageURL = URL(string: imageURL)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        status = try container.decodeIfPresent(Int.self, forKey: .status)
    }
}

public struct ShopShipmentData: Equatable {
    public let isAvailable: Bool
    public let code: String
    public let shipmentID: String
    public let image: URL?
    public let name: String
    public let products: [ShipmentProductData]
    public let isPickup: Bool
    public let maxAddFee: Int?
    public let awbStatus: Int?

    public init(isAvailable: Bool, code: String, shipmentID: String, image: URL?, name: String, products: [ShipmentProductData], isPickup: Bool, maxAddFee: Int?, awbStatus: Int?) {
        self.isAvailable = isAvailable
        self.code = code
        self.shipmentID = shipmentID
        self.image = image
        self.name = name
        self.products = products
        self.isPickup = isPickup
        self.maxAddFee = maxAddFee
        self.awbStatus = awbStatus
    }
}

extension ShopShipmentData: Decodable {
    private enum CodingKeys: String, CodingKey {
        case isAvailable, code, shipmentID, image, name, isPickup, maxAddFee, awbStatus
        case products = "product"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let isAvailable = try container.decodeIfPresent(Int.self, forKey: .isAvailable) ?? 0
        self.isAvailable = isAvailable == 1
        code = try container.decodeIfPresent(String.self, forKey: .code) ?? ""
        shipmentID = try container.decodeIfPresent(String.self, forKey: .shipmentID) ?? ""
        let imageUrl = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        image = URL(string: imageUrl)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        products = try container.decodeIfPresent([ShipmentProductData].self, forKey: .products) ?? []
        let isPickup = try container.decodeIfPresent(Int.self, forKey: .isPickup) ?? 0
        self.isPickup = isPickup == 1
        maxAddFee = try container.decodeIfPresent(Int.self, forKey: .maxAddFee)
        awbStatus = try container.decodeIfPresent(Int.self, forKey: .awbStatus)
    }
}

public struct ShipmentProductData: Equatable {
    public let isAvailable: Bool
    public let productName: String
    public let shipProdID: String
    public let uiHidden: Bool

    public init(isAvailable: Bool, productName: String, shipProdID: String, uiHidden: Bool) {
        self.isAvailable = isAvailable
        self.productName = productName
        self.shipProdID = shipProdID
        self.uiHidden = uiHidden
    }
}

extension ShipmentProductData: Decodable {
    private enum CodingKeys: String, CodingKey {
        case isAvailable, productName, shipProdID, uiHidden
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let isAvailable = try container.decodeIfPresent(Int.self, forKey: .isAvailable) ?? 0
        self.isAvailable = isAvailable == 1
        productName = try container.decodeIfPresent(String.self, forKey: .productName) ?? ""
        shipProdID = try container.decodeIfPresent(String.self, forKey: .shipProdID) ?? ""
        uiHidden = try container.decodeIfPresent(Bool.self, forKey: .uiHidden) ?? false
    }
}

public struct FavoriteData: Equatable {
    public let totalFavorite: Int
    public let alreadyFavorited: Bool

    public init(totalFavorite: Int, alreadyFavorited: Bool) {
        self.totalFavorite = totalFavorite
        self.alreadyFavorited = alreadyFavorited
    }
}

extension FavoriteData: Decodable {
    private enum CodingKeys: String, CodingKey {
        case totalFavorite, alreadyFavorited
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalFavorite = try container.decodeIfPresent(Int.self, forKey: .totalFavorite) ?? 0
        let alreadyFavorited = try container.decodeIfPresent(Int.self, forKey: .alreadyFavorited) ?? 0
        self.alreadyFavorited = alreadyFavorited == 1
    }
}

public struct CreateData: Decodable, Equatable {
    public let shopCreated: String?
    public let epochShopCreatedUTC: String
    public let openSince: String?

    public init(shopCreated: String?, epochShopCreatedUTC: String, openSince: String?) {
        self.shopCreated = shopCreated
        self.epochShopCreatedUTC = epochShopCreatedUTC
        self.openSince = openSince
    }
}

public struct ImageData: Equatable {
    public let avatar: URL?
    public let cover: URL?

    public init(avatar: URL?, cover: URL?) {
        self.avatar = avatar
        self.cover = cover
    }
}

extension ImageData: Decodable {
    private enum CodingKeys: String, CodingKey {
        case avatar, cover
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatar) ?? ""
        avatar = URL(string: avatarUrl)
        let coverUrl = try container.decodeIfPresent(String.self, forKey: .cover) ?? ""
        cover = URL(string: coverUrl)
    }
}

public struct ShopCoreData: Equatable {
    public let shopID: String
    public let domain: String
    public let name: String
    public let description: String
    public let ownerID: String
    public let tagLine: String
    public let url: String
    public let defaultSort: Int

    public init(shopID: String, domain: String, name: String, description: String, ownerID: String, tagLine: String, url: String, defaultSort: Int) {
        self.shopID = shopID
        self.domain = domain
        self.name = name
        self.description = description
        self.ownerID = ownerID
        self.tagLine = tagLine
        self.url = url
        self.defaultSort = defaultSort
    }
}

extension ShopCoreData: Decodable {
    private enum CodingKeys: String, CodingKey {
        case shopID, domain, name, description, ownerID, tagLine, url, defaultSort
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shopID = try container.decodeIfPresent(String.self, forKey: .shopID) ?? ""
        domain = try container.decodeIfPresent(String.self, forKey: .domain) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        ownerID = try container.decodeIfPresent(String.self, forKey: .ownerID) ?? ""
        tagLine = try container.decodeIfPresent(String.self, forKey: .tagLine) ?? ""
        url = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
        defaultSort = try container.decodeIfPresent(Int.self, forKey: .defaultSort) ?? 0
    }
}

public struct StatusData: Equatable {
    public enum TickerType: String {
        case info
        case warning
        case danger
    }

    public let shopStatus: ShopStatusType
    public let statusMessage: String
    public let statusTitle: String
    public let isIdle: Bool
    public let tickerType: TickerType

    public init(
        shopStatus: ShopStatusType,
        statusMessage: String,
        statusTitle: String,
        isIdle: Bool,
        tickerType: TickerType
    ) {
        self.shopStatus = shopStatus
        self.statusMessage = statusMessage
        self.statusTitle = statusTitle
        self.isIdle = isIdle
        self.tickerType = tickerType
    }
}

extension StatusData: Decodable {
    private enum CodingKeys: String, CodingKey {
        case shopStatus, statusMessage, statusTitle, isIdle, tickerType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let shopStatusType = try container.decodeIfPresent(Int.self, forKey: .shopStatus) ?? 1
        shopStatus = ShopStatusType(rawValue: shopStatusType) ?? .open
        statusMessage = try container.decodeIfPresent(String.self, forKey: .statusMessage) ?? ""
        statusTitle = try container.decodeIfPresent(String.self, forKey: .statusTitle) ?? ""
        isIdle = try container.decodeIfPresent(Bool.self, forKey: .isIdle) ?? false
        let tickerStringType = try container.decodeIfPresent(String.self, forKey: .tickerType) ?? ""
        // if we got new unmapped type, the default will be info
        tickerType = TickerType(rawValue: tickerStringType) ?? .info
    }
}

public enum ShopStatusType: Int, Equatable {
    case deleted = 0
    case open = 1
    case closed = 2
    case moderated = 3
    case inactive = 4
    case moderatedPermanently = 5
    case incubated = 6
    case incomplete = 7
}

public struct GoldOSData: Equatable {
    public let isGoldBadge: Bool
    public let isKYC: Bool
    public let title: String
    public let badge: URL?
    public let isGoldMerchant: Bool
    public let isOfficialStore: Bool
    public let shopType: ShopType

    public init(isGoldBadge: Bool, isKYC: Bool, title: String, badge: URL?, isGoldMerchant: Bool, isOfficialStore: Bool, shopType: ShopType) {
        self.isGoldBadge = isGoldBadge
        self.isKYC = isKYC
        self.title = title
        self.badge = badge
        self.isGoldMerchant = isGoldMerchant
        self.isOfficialStore = isOfficialStore
        self.shopType = shopType
    }
}

extension GoldOSData: Decodable {
    private enum CodingKeys: String, CodingKey {
        case isGold, isGoldBadge, isOfficial, isKYC, title, badge
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let isGoldBadge = try container.decodeIfPresent(Int.self, forKey: .isGoldBadge) ?? 0
        self.isGoldBadge = isGoldBadge == 1

        let isOfficial = try container.decodeIfPresent(Int.self, forKey: .isOfficial) ?? 0
        isOfficialStore = isOfficial == 1

        let isGold = try container.decodeIfPresent(Int.self, forKey: .isGold) ?? 0
        isGoldMerchant = isGold == 1

        if isOfficial == 1 {
            shopType = .official
        } else if isGold == 1 {
            shopType = .gold
        } else {
            shopType = .regular
        }
        let isKYC = try container.decodeIfPresent(Int.self, forKey: .isKYC) ?? 0
        self.isKYC = isKYC == 1
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        let badgeUrl = try container.decodeIfPresent(String.self, forKey: .badge) ?? ""
        badge = URL(string: badgeUrl)
    }
}

public struct StatsData: Decodable, Equatable {
    public let productSold: String
    public let totalTx: String
    public let totalShowcase: String

    public init(productSold: String, totalTx: String, totalShowcase: String) {
        self.productSold = productSold
        self.totalTx = totalTx
        self.totalShowcase = totalShowcase
    }
}

// a.k.a ShippingLocData in GQL
public struct ShippingLocationData: Decodable, Equatable {
    public let districtID: String
    public let districtName: String
    public let postalCode: String
    public let addressStreet: String
    public let latitude: String
    public let longitude: String
    public let provinceID: String
    public let provinceName: String
    public let cityID: Int
    public let cityName: String
    public let countryName: String
}

public struct BlackBoxData: Decodable, Equatable {
    public let name: String
    public let description: String

    private enum CodingKeys: String, CodingKey {
        case name = "bbName"
        case description = "bbDesc"
    }
}

public struct ShopTopContent: Decodable, Equatable {
    public let topURL: URL?
    public let bottomURL: URL?

    public init(topURL: URL?, bottomURL: URL?) {
        self.topURL = topURL
        self.bottomURL = bottomURL
    }

    private enum CodingKeys: String, CodingKey {
        case topURL, bottomURL
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let topURL = try container.decodeIfPresent(String.self, forKey: .topURL) ?? ""
        self.topURL = URL(string: topURL)
        let bottomURL = try container.decodeIfPresent(String.self, forKey: .bottomURL) ?? ""
        self.bottomURL = URL(string: bottomURL)
    }
}

public struct ShopFreeShipping: Decodable, Equatable {
    public let isActive: Bool
    public let imgUrl: String

    public init(isActive: Bool, imgUrl: String) {
        self.isActive = isActive
        self.imgUrl = imgUrl
    }

    private enum CodingKeys: String, CodingKey {
        case isActive
        case imgUrl = "imgURL"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? false
        imgUrl = try container.decodeIfPresent(String.self, forKey: .imgUrl) ?? ""
    }
}

/// Documentation: https://tokopedia.atlassian.net/wiki/spaces/TISR/pages/1064599650/Get+Partner+Shop+Label
public enum PartnerType: Int, Decodable, Equatable {
    case defaultType = 0
    case tokoCabang = 1
    case ePharmacy = 2
    case newRetail = 3
    case tokoNow = 4
    case b2b2c = 5
}

public struct PartnerInfoData: Decodable, Equatable {
    @DecodableDefault.PartnerTypeDefault internal var fsType: PartnerType
}


public struct ShopEPharmacyInfo: Equatable {
    public let siaNumber: String
    public let sipaNumber: String
    public let apj: String

    public init(siaNumber: String, sipaNumber: String, apj: String) {
        self.siaNumber = siaNumber
        self.sipaNumber = sipaNumber
        self.apj = apj
    }
}

extension ShopEPharmacyInfo: Decodable {}

extension DecodableDefault {
    internal typealias PartnerTypeDefault = Wrapper<PartnerInfoDefault>

    internal enum PartnerInfoDefault: Source {
        internal static var defaultValue: PartnerType {
            PartnerType.defaultType
        }
    }
}

public protocol DecodableDefaultSource {
    associatedtype Value: Decodable
    static var defaultValue: Value { get }
}

public enum DecodableDefault {}

extension DecodableDefault {
    @propertyWrapper
    public struct Wrapper<Source: DecodableDefaultSource> {
        public typealias Value = Source.Value
        public var wrappedValue: Value

        public init(wrappedValue: Value) {
            self.wrappedValue = wrappedValue
        }

        public init() {
            wrappedValue = Source.defaultValue
        }
    }
}

extension DecodableDefault.Wrapper: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Value.self)
    }
}

extension KeyedDecodingContainer {
    public func decode<T>(_ type: DecodableDefault.Wrapper<T>.Type,
                          forKey key: Key) throws -> DecodableDefault.Wrapper<T> {
        // if the decoding fails, we initialise with default value
        return (try? decodeIfPresent(type, forKey: key)) ?? .init()
    }
}

extension DecodableDefault.Wrapper: Equatable where Value: Equatable {}
extension DecodableDefault.Wrapper: Hashable where Value: Hashable {}

extension DecodableDefault.Wrapper: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}


public enum ShopType: Int, Equatable {
    case regular, gold, official

    public var description: String {
        switch self {
        case .regular: return "regular_merchant"
        case .gold: return "power_merchant"
        case .official: return "official_store"
        }
    }

    public var text: String {
        switch self {
        case .regular:
            return "regular"
        case .gold:
            return "gold_merchant"
        case .official:
            return "official_store"
        }
    }
}

extension DecodableDefault {
    public typealias Source = DecodableDefaultSource
    public typealias Array = Decodable & ExpressibleByArrayLiteral
    public typealias Dict = Decodable & ExpressibleByDictionaryLiteral

    public enum Sources {
        public enum True: Source {
            public static var defaultValue: Bool { true }
        }

        public enum False: Source {
            public static var defaultValue: Bool { false }
        }

        public enum EmptyString: Source {
            public static var defaultValue: String { "" }
        }

        public enum EmptyArray<T: Array>: Source {
            public static var defaultValue: T { [] }
        }

        public enum EmptyDictionary<T: Dict>: Source {
            public static var defaultValue: T { [:] }
        }

        public enum UUIDString: Source {
            public static var defaultValue: String { UUID().uuidString }
        }

        public enum Uuid: Source {
            public static var defaultValue: UUID { UUID() }
        }
    }
}

// Typealias for shorthand notation
extension DecodableDefault {
    public typealias True = Wrapper<Sources.True>
    public typealias False = Wrapper<Sources.False>
    public typealias EmptyString = Wrapper<Sources.EmptyString>
    public typealias EmptyArray<T: Array> = Wrapper<Sources.EmptyArray<T>>
    public typealias EmptyDictionary<T: Dict> = Wrapper<Sources.EmptyDictionary<T>>
    public typealias UUIDString = Wrapper<Sources.UUIDString>
    public typealias Uuid = Wrapper<Sources.Uuid>
}
