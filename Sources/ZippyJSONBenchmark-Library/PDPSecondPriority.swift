import Foundation
import IdentifiedCollections

internal struct ReviewListData: Decodable, Equatable {
    internal let title: String
    internal let appLinkTitle: String
    internal let appLink: String
    internal let items: [ReviewListItemData]

    private enum CodingKeys: String, CodingKey {
        case title
        case appLinkTitle = "applinkTitle"
        case appLink = "applink"
        case items = "data"
    }
}

internal struct ReviewListItemData: Decodable, Equatable {
    internal let userImage: String
    internal let userName: String
    internal let userTitle: String
    internal let userSubtitle: String
    internal let reviewText: String
    internal let reviewId: String
    internal let appLink: String

    private enum CodingKeys: String, CodingKey {
        case userImage, userName, userTitle, userSubtitle, reviewText
        case reviewId = "reviewID"
        case appLink = "applink"
    }
}

internal struct SocialProofData: Decodable, Equatable {
    internal let socialProofId: SocialProofId
    internal let type: SocialProofType
    internal let title: String
    internal let subtitle: String
    internal let iconUrlString: String
    internal let appLink: String

    private enum CodingKeys: String, CodingKey {
        case title, subtitle, applink
        case socialProofId = "socialProofID"
        case type = "socialProofType"
        case iconUrlString = "icon"
    }

    private enum AppLinkCodingKeys: String, CodingKey {
        case appLink
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        socialProofId = try container.decode(SocialProofId.self, forKey: .socialProofId)
        type = try container.decode(SocialProofType.self, forKey: .type)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        iconUrlString = try container.decode(String.self, forKey: .iconUrlString)

        let appLinkContainer = try container.nestedContainer(keyedBy: AppLinkCodingKeys.self, forKey: .applink)
        appLink = try appLinkContainer.decode(String.self, forKey: .appLink)
    }

    internal init(socialProofId: SocialProofId,
                  type: SocialProofType,
                  title: String,
                  subtitle: String,
                  iconUrlString: String,
                  appLink: String) {
        self.socialProofId = socialProofId
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.iconUrlString = iconUrlString
        self.appLink = appLink
    }
}

internal enum SocialProofId: String, Decodable, Equatable {
    case none = ""
    case talk
    case rating
    case media
    case shopRating = "shop_rating"
    case newProduct = "new_product"
}

internal struct RatingData: Decodable, Equatable {
    internal let ratingScore: String
    internal let totalRating: String
    internal let totalReviewTextAndImage: String
}

internal enum SocialProofType: String, Decodable, Equatable {
    case text
    case chip
    case orangeChip = "orange_chip"
}

internal struct MostHelpfulReview: Decodable, Equatable {
    internal let list: [ProductReviewGQL]
}

// a.k.a PDPReviewType
internal struct ProductReviewGQL: Decodable, Equatable {
    internal let reviewId: String
    internal let message: String
    internal let productRating: Int
    internal let reviewCreateTime: String
    internal let user: ProductReviewUser
    internal let imageAttachments: [ProductReviewAttachment]
    internal let videoAttachments: [ProductReviewVideoAttachment]
    internal let likeDislike: ProductReviewLikeDislike
    internal let variant: ProductReviewVariant
    internal let userLabel: String
    internal let userStat: [ProductReviewStats]
}

internal struct ProductReviewStats: Decodable, Equatable, Identifiable {
    internal var id: String {
        key
    }

    internal let key: String
    internal let formatted: String
}

internal struct ProductReviewVideoAttachment: Decodable, Equatable {
    internal let videoUrl: String
    internal let attachmentID: String
}

internal struct ProductReviewUser: Decodable, Equatable {
    internal let userId: String
    internal let fullName: String
    internal let imageUrl: URL?

    internal init(userId: String, fullName: String, imageUrl: URL?) {
        self.userId = userId
        self.fullName = fullName
        self.imageUrl = imageUrl
    }

    private enum CodingKeys: String, CodingKey {
        case userId, fullName
        case imageUrl = "image"
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(String.self, forKey: .userId)
        fullName = try container.decode(String.self, forKey: .fullName)
        let image = try container.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        imageUrl = URL(string: image)
    }
}

public struct ProductImageReview: Equatable {
    public let reviewID: String
    public let message: String
    public let ratingDescription: String
    public let rating: Int
    public let reviewer: ReviewerData

    public init(reviewID: String, message: String, ratingDescription: String, rating: Int, reviewer: ReviewerData) {
        self.reviewID = reviewID
        self.message = message
        self.ratingDescription = ratingDescription
        self.rating = rating
        self.reviewer = reviewer
    }
}

public struct ReviewerData: Equatable {
    public let userID: Int
    public let fullName: String
    public let profilePicture: String
    public let url: String?
}

extension ReviewerData: Decodable {
    private enum CodingKeys: String, CodingKey {
        case userID, fullName, profilePicture, url
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userID = try container.decodeIfPresent(Int.self, forKey: .userID) ?? 0
        fullName = try container.decodeIfPresent(String.self, forKey: .fullName) ?? ""
        profilePicture = try container.decodeIfPresent(String.self, forKey: .profilePicture) ?? ""
        url = try container.decodeIfPresent(String.self, forKey: .url)
    }
}


public struct ProductReviewImages: Equatable, Identifiable {
    public let id: Int
    public let description: String
    public let urlThumbnail: String
    public let urlLarge: String
    public var review: ProductImageReview?

    public init(id: Int, description: String, urlThumbnail: String, urlLarge: String, review: ProductImageReview? = nil) {
        self.id = id
        self.description = description
        self.urlThumbnail = urlThumbnail
        self.urlLarge = urlLarge
        self.review = review
    }
}


internal struct ProductReviewAttachment: Decodable, Equatable {
    internal let id: String
    internal let description: String
    internal let thumbnailUrl: URL?
    internal let url: URL?

    internal var productReviewImageFormat: ProductReviewImages {
        return ProductReviewImages(id: Int(id) ?? 0, description: description, urlThumbnail: thumbnailUrl?.absoluteString ?? "", urlLarge: url?.absoluteString ?? "")
    }

    private enum CodingKeys: String, CodingKey {
        case id = "attachmentId"
        case description
        case thumbnailUrl = "imageThumbnailUrl"
        case url = "imageUrl"
    }

    internal init(id: String, description: String, thumbnailUrl: URL?, url: URL?) {
        self.id = id
        self.description = description
        self.thumbnailUrl = thumbnailUrl
        self.url = url
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        let thumbnailUrl = try container.decodeIfPresent(String.self, forKey: .thumbnailUrl) ?? ""
        self.thumbnailUrl = URL(string: thumbnailUrl)
        let url = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
        self.url = URL(string: url)
    }
}

internal struct ProductReviewLikeDislike: Decodable, Equatable {
    internal let totalLike: Int
    internal let totalDislike: Int
    internal let isShowable: Bool

    private enum CodingKeys: String, CodingKey {
        case totalLike = "TotalLike"
        case totalDislike = "TotalDislike"
        case isShowable
    }
}

internal struct ProductReviewVariant: Decodable, Equatable {
    internal let name: String
}

internal struct ReviewImagesList: Equatable {
    internal let list: [ImageList]
    internal let detail: DetailReview?
    internal let hasNext: Bool
    internal let hasPrev: Bool
}

extension ReviewImagesList: Decodable {
    private enum CodingKeys: String, CodingKey {
        case list, detail, hasNext, hasPrev
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let list = try container.decodeIfPresent([ImageList].self, forKey: .list)
        let detail = try container.decodeIfPresent(DetailReview.self, forKey: .detail)
        let hasNext = try container.decodeIfPresent(Bool.self, forKey: .hasNext)
        let hasPrev = try container.decodeIfPresent(Bool.self, forKey: .hasPrev)

        self.init(list: list ?? [], detail: detail, hasNext: hasNext ?? false, hasPrev: hasPrev ?? false)
    }
}

internal struct ImageList: Equatable {
    internal let imageID: Int?
    internal let videoID: String?
    internal let reviewID: Int?
    internal let imageSibling: [Int]
}

extension ImageList: Decodable {
    private enum CodingKeys: String, CodingKey {
        case imageID, reviewID, videoID, imageSibling
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let imageID = try container.decodeIfPresent(Int.self, forKey: .imageID)
        let videoID = try container.decodeIfPresent(String.self, forKey: .videoID)
        let reviewID = try container.decodeIfPresent(Int.self, forKey: .reviewID)
        let imageSibling = try container.decodeIfPresent([Int].self, forKey: .imageSibling)

        self.init(
            imageID: imageID,
            videoID: videoID,
            reviewID: reviewID,
            imageSibling: imageSibling ?? []
        )
    }
}

internal struct VideoDetail: Decodable, Equatable {
    internal let attachmentID: String?
    internal let url: String?
    internal let feedbackID: String?
}

internal struct DetailReview: Equatable {
    internal let reviews: [ListReview]
    internal let images: [ListImagesDetail]
    internal let videos: [VideoDetail]
    internal let mediaCountFmt: String
    internal let mediaCount: String
    internal let imageCountFmt: String
    internal let imageCount: String
    internal let mediaCountTitle: String
}

extension DetailReview: Decodable {
    private enum CodingKeys: String, CodingKey {
        case reviews, images, videos, mediaCountFmt, mediaCount, imageCountFmt, imageCount, mediaCountTitle
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let reviews = try container.decodeIfPresent([ListReview].self, forKey: .reviews)
        let images = try container.decodeIfPresent([ListImagesDetail].self, forKey: .images)
        let videos = try container.decodeIfPresent([VideoDetail].self, forKey: .videos)
        let mediaCountFmt = try container.decodeIfPresent(String.self, forKey: .mediaCountFmt)
        let mediaCount = try container.decodeIfPresent(String.self, forKey: .mediaCount)
        let imageCountFmt = try container.decodeIfPresent(String.self, forKey: .imageCountFmt)
        let imageCount = try container.decodeIfPresent(String.self, forKey: .imageCount)
        let mediaCountTitle = try container.decodeIfPresent(String.self, forKey: .mediaCountTitle)

        self.init(
            reviews: reviews ?? [],
            images: images ?? [],
            videos: videos ?? [],
            mediaCountFmt: mediaCountFmt ?? "",
            mediaCount: mediaCount ?? "",
            imageCountFmt: imageCountFmt ?? "",
            imageCount: imageCount ?? "",
            mediaCountTitle: mediaCountTitle ?? ""
        )
    }
}

internal struct ListReview: Decodable, Equatable {
    internal let reviewId: Int?
    internal let message: String?
    internal let ratingDescription: String?
    internal let rating: Int?
    internal let updateTime: Int?
    internal let isAnonymous: Bool?
    internal let isReportable: Bool?
    internal let isUpdated: Bool?
    internal let reviewer: ReviewerData?

    private enum CodingKeys: String, CodingKey {
        case reviewId, message, ratingDescription, rating, updateTime, isAnonymous, isReportable, isUpdated, reviewer
    }
}

internal struct ListImagesDetail: Decodable, Equatable {
    internal let imageAttachmentID: Int?
    internal let description: String?
    internal let uriThumbnail: String?
    internal let uriLarge: String?
    internal let reviewID: Int?
}

public struct ShopCommitmentResponse: Decodable, Equatable {
    public var result: ShopCommitment
    public let error: ShopCommitmentError
}

public struct ShopCommitment: Decodable, Equatable {
    public var isNowActive: Bool
    public let staticMessages: ShopCommitmentStaticMessage
    public let iconURL: String
}

public struct ShopCommitmentStaticMessage: Decodable, Equatable {
    public let pdpMessage: String
}

public struct ShopCommitmentError: Decodable, Equatable {
    public let message: String
}

internal struct ShopChatSpeed: Decodable, Equatable {
    internal let messageResponseTime: String
}

internal struct ShopRating: Decodable, Equatable {
    internal let ratingScore: Float
}

internal struct ShopPackingSpeed: Decodable, Equatable {
    internal let hour: Int
    internal let speedFmt: String
}

internal struct PDPShopReputation: Decodable, Equatable {
    internal let badge: String
    internal let score: String
}

public struct VariantWarehouseInfo: Decodable, Equatable {
    public let warehouseID: String
    public var isFulfillment: Bool
    public var productID: String
    public var districtID: String
    public var postalCode: String
    public var geolocation: String

    private enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case warehouseInfo = "warehouse_info"
    }

    private enum WarehouseKeys: String, CodingKey {
        case warehouseID = "warehouse_id"
        case isFulfillment = "is_fulfillment"
        case districtID = "district_id"
        case postalCode = "postal_code"
        case geolocation
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productID = try container.decode(String.self, forKey: .productID)
        let warehouseData = try container.nestedContainer(keyedBy: WarehouseKeys.self, forKey: .warehouseInfo)
        warehouseID = try warehouseData.decode(String.self, forKey: .warehouseID)
        isFulfillment = try warehouseData.decode(Bool.self, forKey: .isFulfillment)
        districtID = try warehouseData.decode(String.self, forKey: .districtID)
        postalCode = try warehouseData.decode(String.self, forKey: .postalCode)
        geolocation = try warehouseData.decode(String.self, forKey: .geolocation)
    }

    public init(warehouseID: String, isFulfillment: Bool, productID: String, districtID: String, postalCode: String, geolocation: String) {
        self.warehouseID = warehouseID
        self.isFulfillment = isFulfillment
        self.productID = productID
        self.districtID = districtID
        self.postalCode = postalCode
        self.geolocation = geolocation
    }
}

public struct VariantShopInfo: Decodable, Equatable {
    public var shopTier: VariantShopTier

    private enum CodingKeys: String, CodingKey {
        case shopTier
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shopTier = try container.decodeIfPresent(Int.self, forKey: .shopTier).flatMap(VariantShopTier.init) ?? .regularMerchant
    }

    public init(shopTier: VariantShopTier) {
        self.shopTier = shopTier
    }
}

public enum VariantShopTier: Int, Equatable {
    case regularMerchant = 0
    case powerMerchant = 1
    case officialStore = 2
    case powerMerchantPro = 3
}

public struct PdpBebasOngkir: Equatable, Decodable {
    public var products: [PdpBoProducts]
    public var images: [PdpBoImages]

    public init(products: [PdpBoProducts], images: [PdpBoImages]) {
        self.products = products
        self.images = images
    }
}

public struct PdpBoProducts: Equatable, Decodable {
    public var productID: String
    public var boType: PdpBoType
    public var boCampaignIDs: String

    private enum CodingKeys: String, CodingKey {
        case productID
        case boType
        case boCampaignIDs
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productID = try container.decode(String.self, forKey: .productID)
        boType = try container.decodeIfPresent(Int.self, forKey: .boType).flatMap(PdpBoType.init) ?? .ineligible
        boCampaignIDs = try container.decode(String.self, forKey: .boCampaignIDs)
    }

    public init(productID: String, boType: PdpBoType, boCampaignIDs: String) {
        self.productID = productID
        self.boType = boType
        self.boCampaignIDs = boCampaignIDs
    }
}

public struct PdpBoImages: Equatable, Decodable {
    public var boType: PdpBoType
    public var imageURL: String

    private enum CodingKeys: String, CodingKey {
        case imageURL
        case boType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        imageURL = try container.decode(String.self, forKey: .imageURL)
        boType = try container.decodeIfPresent(Int.self, forKey: .boType).flatMap(PdpBoType.init) ?? .ineligible
    }

    public init(boType: PdpBoType, imageURL: String) {
        self.boType = boType
        self.imageURL = imageURL
    }
}

public struct PdpProductFreeOngkir: Equatable, Identifiable {
    public var id: String
    public var boType: PdpBoType
    public var imageURL: String
    public var boCampaignIDs: String

    public var isBebasOngkir: Bool {
        boType == .bebasOngkir || boType == .bebasOngkirExtra
    }

    public init(id: String, boType: PdpBoType, imageURL: String, boCampaignIDs: String) {
        self.id = id
        self.boType = boType
        self.imageURL = imageURL
        self.boCampaignIDs = boCampaignIDs
    }
}

public struct ProductInfoPreorder: Decodable, Equatable {
    public let isActive: Bool
    public let duration: Int
    public let timeUnit: PreorderTimeUnit
    public let preorderInDays: Int

    public init(isActive: Bool, duration: Int, timeUnit: PreorderTimeUnit, preorderInDays: Int) {
        self.isActive = isActive
        self.duration = duration
        self.timeUnit = timeUnit
        self.preorderInDays = preorderInDays
    }

    private enum CodingKeys: String, CodingKey {
        case isActive, duration, timeUnit, preorderInDays
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        duration = try container.decode(Int.self, forKey: .duration)
        let timeUnitString = try container.decodeIfPresent(String.self, forKey: .timeUnit) ?? ""
        timeUnit = PreorderTimeUnit(rawValue: timeUnitString) ?? .unknown
        preorderInDays = try container.decode(Int.self, forKey: .preorderInDays)
    }
}

public struct ProductCashback: Decodable, Equatable {
    public var percentage: Int?

    public init(percentage: Int? = nil) {
        self.percentage = percentage
    }
}

public struct PdpUniqueSellingPoint: Equatable {
    public var iconBebasOngkirExtra: String

    public init(iconBebasOngkirExtra: String) {
        self.iconBebasOngkirExtra = iconBebasOngkirExtra
    }
}

extension PdpUniqueSellingPoint: Decodable {
    private enum CodingKeys: String, CodingKey {
        case bebasOngkirExtra
        case iconBebasOngkirExtra = "icon"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let bebasOngkirExtra = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .bebasOngkirExtra)
        iconBebasOngkirExtra = try bebasOngkirExtra.decode(String.self, forKey: .iconBebasOngkirExtra)
    }
}

public enum PdpBoType: Int, Equatable, Codable {
    case ineligible = 0
    case bebasOngkir
    case bebasOngkirExtra
    case tokoNow2h
    case tokoNow15m
    case bebasOngkirPlus
    case bebasOngkirPlusDT

    public var boNameTracker: String {
        switch self {
        case .bebasOngkir:
            return "bebas ongkir"
        case .bebasOngkirExtra:
            return "bebas ongkir extra"
        case .ineligible:
            return "none / other"
        case .tokoNow2h, .tokoNow15m:
            return "tokonow"
        case .bebasOngkirPlus, .bebasOngkirPlusDT:
            return "bebas ongkir plus"
        }
    }

    public var isTokonow: Bool {
        return self == .tokoNow2h || self == .tokoNow15m
    }
}

public enum VariantComponentType: String, Equatable, Decodable {
    case thumbnail
    case miniVariant
}

internal struct PDPDataUpcomingDeals: Equatable {
    internal let campaignID: String
    internal let campaignType: String
    internal let campaignTypeName: String
    internal let endDate: Int64
    internal var startDate: Int64
    internal var isRegistered: Bool
    internal var ribbonCopy: String
    internal var upcomingType: PDPUpcomingType
    internal let productID: String
    internal var bgColor: String

    // show the ribbon when less than 24 hour
    internal var isShowRibbon: Bool {
        return lessThan24HoursFromNow(startDate)
    }

    private func lessThan24HoursFromNow(_ endDateUnix: Int64) -> Bool {
        let interval = TimeInterval(endDateUnix)
        let endDate = Date(timeIntervalSince1970: interval)
        let components = Calendar.current.dateComponents([.hour],
                                                         from: Date(),
                                                         to: endDate)
        guard let hour = components.hour else { return false }
        return hour < 24
    }
}

extension PDPDataUpcomingDeals: Decodable {
    internal enum CodingKeys: String, CodingKey {
        case campaignID, campaignType, campaignTypeName, endDate, startDate, ribbonCopy, upcomingType, productID, bgColor
        case isRegistered = "notifyMe"
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        campaignID = try container.decode(String.self, forKey: .campaignID)
        campaignType = try container.decode(String.self, forKey: .campaignType)
        campaignTypeName = try container.decode(String.self, forKey: .campaignTypeName)
        isRegistered = try container.decode(Bool.self, forKey: .isRegistered)
        endDate = Int64(try container.decode(String.self, forKey: .endDate)) ?? 0
        startDate = Int64(try container.decode(String.self, forKey: .startDate)) ?? 0
        ribbonCopy = try container.decode(String.self, forKey: .ribbonCopy)
        upcomingType = try container.decodeIfPresent(String.self, forKey: .upcomingType).flatMap(PDPUpcomingType.init) ?? .none
        productID = try container.decode(String.self, forKey: .productID)
        bgColor = try container.decode(String.self, forKey: .bgColor)
    }
}

internal enum PDPUpcomingType: String {
    case npl = "UPCOMING_NPL"
    case deals = "UPCOMING_DEALS"
    case none
}

public enum PreorderTimeUnit: String, Decodable, Equatable {
    case day = "DAY"
    case week = "WEEK"
    case month = "MONTH"
    case unknown = "UNKNOWN"

    internal var text: String {
        switch self {
        case .day: return "Hari"
        case .week: return "Minggu"
        case .month: return "Bulan"
        case .unknown: return ""
        }
    }
}

public struct CartRedirection: Decodable, Equatable {
    public let errorMessage: [String]
    public let status: String
    public var data: [CartRedirectionData]
    public var alternateCopy: [AlternateCopyButton]?

    private enum CodingKeys: String, CodingKey {
        case data, status
        case errorMessage = "error_message"
        case alternateCopy = "alternate_copy"
    }

    public init(errorMessage: [String], status: String, data: [CartRedirectionData], alternateCopy: [AlternateCopyButton]? = nil) {
        self.errorMessage = errorMessage
        self.status = status
        self.data = data
        self.alternateCopy = alternateCopy
    }
}

public enum UnavailableBtn: String, Decodable, Equatable {
    case chat
}

public struct CartRedirectionData: Decodable, Equatable {
    public let configName: String
    public var availableButtons: [CartRedirectionButton]
    public let unavailableButtons: [UnavailableBtn]
    public let productId: String
    public let hideFloatingButton: Bool

    private enum CodingKeys: String, CodingKey {
        case configName = "config_name"
        case availableButtons = "available_buttons"
        case unavailableButtons = "unavailable_buttons"
        case productId = "product_id"
        case hideFloatingButton = "hide_floating_button"
    }

    public init(configName: String, availableButtons: [CartRedirectionButton], unavailableButtons: [UnavailableBtn], productId: String, hideFloatingButton: Bool) {
        self.configName = configName
        self.availableButtons = availableButtons
        self.unavailableButtons = unavailableButtons
        self.productId = productId
        self.hideFloatingButton = hideFloatingButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        configName = try container.decode(String.self, forKey: .configName)
        availableButtons = try container.decode([CartRedirectionButton].self, forKey: .availableButtons)
        unavailableButtons = try container.decode([String].self, forKey: .unavailableButtons).compactMap(UnavailableBtn.init)
        productId = try container.decode(String.self, forKey: .productId)
        hideFloatingButton = try container.decode(Bool.self, forKey: .hideFloatingButton)
    }
}

public struct AlternateCopyButton: Decodable, Equatable {
    public var text: String
    public var cartType: CartType
    public var color: CartButtonColorType

    private enum CodingKeys: String, CodingKey {
        case text, color
        case cartType = "cart_type"
    }

    public init(text: String, color: CartButtonColorType, cartType: CartType) {
        self.text = text
        self.color = color
        self.cartType = cartType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        let buttonColor = try container.decode(String.self, forKey: .color)
        color = CartButtonColorType(rawValue: buttonColor) ?? .secondary
        let cart = try container.decode(String.self, forKey: .cartType)
        cartType = CartType(rawValue: cart) ?? .normal
    }
}

public enum CartType: String, Decodable, Equatable {
    case normal // go to cart
    case ocs
    case occ
    case remindMe = "remind_me" // wishlist
    case checkWishlist = "check_wishlist" // move to wishlist
    case chooseVariant = "default_choose_variant"
}

public enum CartButtonColorType: String, Decodable {
    // orange
    case primary
    // green button
    case primary_green
    // white with border orange
    case secondary
    // white with border green
    case secondary_green
    // white with border gray
    case secondary_gray
    // disable
    case disabled
}


public struct CartRedirectionButton: Decodable, Equatable {
    public var text: String
    public var color: CartButtonColorType
    public var cartType: CartType
    public let showRecommendation: Bool

    private enum CodingKeys: String, CodingKey {
        case text, color
        case cartType = "cart_type"
        case showRecommendation = "show_recommendation"
    }

    public init(text: String, color: CartButtonColorType, cartType: CartType, showRecommendation: Bool) {
        self.text = text
        self.color = color
        self.cartType = cartType
        self.showRecommendation = showRecommendation
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        let buttonColor = try container.decode(String.self, forKey: .color)
        color = CartButtonColorType(rawValue: buttonColor) ?? .secondary
        let cart = try container.decode(String.self, forKey: .cartType)
        cartType = CartType(rawValue: cart) ?? .normal
        showRecommendation = try container.decode(Bool.self, forKey: .showRecommendation)
    }
}

public struct TradeInDeviceInfo: Decodable, Equatable {
    public var minPrice: Int = 0
    public var modelId: Int = 0
    public var modelDisplayName: String = ""
    public var maxPrice: Int = 0
    public var brand: String = ""
    public var model: String = ""

    public init(minPrice: Int, modelId: Int, modelDisplayName: String, maxPrice: Int, brand: String, model: String) {
        self.minPrice = minPrice
        self.modelId = modelId
        self.modelDisplayName = modelDisplayName
        self.maxPrice = maxPrice
        self.brand = brand
        self.model = model
    }

    private enum CodingKeys: String, CodingKey {
        case minPrice = "min_price"
        case modelId = "model_id"
        case modelDisplayName = "model_display_name"
        case maxPrice = "max_price"
        case brand
        case model
    }
}


internal struct TradeIn: Decodable, Equatable {
    internal var isEligible: Bool
    internal var isDiagnosed: Bool
    internal let useKyc: Bool
    internal let usedPrice: String
    internal let remainingPrice: String
    internal let message: String
    internal var deviceInfo: TradeInDeviceInfo?
    internal let widgetString: String

    private enum CodingKeys: String, CodingKey {
        case isEligible
        case isDiagnosed
        case useKyc
        case usedPrice
        case remainingPrice
        case message
        case widgetString
    }
}

internal struct FtInstallmentCalculation: Decodable, Equatable {
    internal let data: FtInstallmentCalculationData
    internal let message: String
}

internal struct TNC: Codable, Equatable {
    internal let tncId: Int
    internal let tncList: [TNCList]

    private enum CodingKeys: String, CodingKey {
        case tncId = "tnc_id"
        case tncList = "tnc_list"
    }
}

internal struct TNCList: Codable, Equatable {
    internal let order: Int
    internal let description: String
}

internal struct FtInstallmentCalculationData: Decodable, Equatable {
    internal let creditCard: [CreditCard]
    internal let nonCreditCard: [CreditCard]
    internal let tnc: [TNC]

    private enum CodingKeys: String, CodingKey {
        case creditCard = "credit_card"
        case nonCreditCard = "non_credit_card"
        case tnc
    }
}

internal struct CreditCardInstallmentList: Codable, Equatable {
    internal let term: Int
    internal let mdrValue: Double
    internal let mdrType: String
    internal let interestRate: Double
    internal let minimumAmount, maximumAmount, monthlyPrice: Double
    internal let osMonthlyPrice: Double

    private enum CodingKeys: String, CodingKey {
        case mdrType = "mdr_type"
        case mdrValue = "mdr_value"
        case osMonthlyPrice = "os_monthly_price"
        case interestRate = "interest_rate"
        case monthlyPrice = "monthly_price"
        case maximumAmount = "maximum_amount"
        case minimumAmount = "minimum_amount"
        case term
    }
}

internal struct InstructionList: Codable, Equatable {
    internal let order: Int
    internal let description, insImageUrl: String

    private enum CodingKeys: String, CodingKey {
        case order
        case description
        case insImageUrl = "ins_image_url"
    }
}


internal struct CreditCard: Decodable, Equatable {
    internal var isExpanded: Bool = false
    internal let uuid = UUID().uuidString
    internal let partnerCode, partnerName, partnerIcon: String
    internal let partnerUrl: String
    internal let tncId: Int
    internal let installmentList: [CreditCardInstallmentList]
    internal let instructionList: [InstructionList]
    internal var tnc: String? = String()

    internal enum CodingKeys: String, CodingKey {
        case partnerCode = "partner_code"
        case partnerName = "partner_name"
        case partnerIcon = "partner_icon"
        case partnerUrl = "partner_url"
        case tncId = "tnc_id"
        case installmentList = "installment_list"
        case instructionList = "instruction_list"
        case tnc
    }
}

internal struct PDPInsurenceModel: Decodable, Equatable {
    internal let program: InsurenceModel
}

internal struct InsurenceModel: Decodable, Equatable {
    internal let protectionAvailable: Bool
    internal let titlePDP: String
    internal let subTitlePDP: String
    internal let iconURL: String
    internal let linkURL: String
    internal let isAppLink: Bool
}

internal struct FtInstallmentRecommendation: Decodable, Equatable {
    internal let message: String
    internal var data: FtInstallmentRecommendationData
}

// MARK: - FtInstallmentRecommendationData

internal struct FtInstallmentRecommendationData: Decodable, Equatable {
    internal let mdrType: String
    internal let subtitle: String
    internal let partnerName: String
    internal let osMonthlyPrice: Double
    internal var partnerCode: String
    internal let interestRate: Double
    internal let monthlyPrice: Double
    internal let mdrValue: Double
    internal let maximumAmount: Double
    internal let partnerIcon: String
    internal let minimumAmount: Double
    internal let term: Int

    private enum CodingKeys: String, CodingKey {
        case mdrType = "mdr_type"
        case subtitle
        case partnerName = "partner_name"
        case osMonthlyPrice = "os_monthly_price"
        case partnerCode = "partner_code"
        case interestRate = "interest_rate"
        case monthlyPrice = "monthly_price"
        case mdrValue = "mdr_value"
        case maximumAmount = "maximum_amount"
        case partnerIcon = "partner_icon"
        case minimumAmount = "minimum_amount"
        case term
    }
}

public struct PdpDataTicker: Equatable, Decodable {
    public var title: String
    public var message: String
    public var color: PdpDataTickerColor
    public var link: String
    public var action: PdpDataTickerAction?
    public var actionLink: String
    public var tickerType: Int
    public var actionBottomSheet: PdpDataTickerMessage

    public init(
        title: String,
        message: String,
        color: PdpDataTickerColor,
        link: String,
        action: PdpDataTickerAction? = nil,
        actionLink: String,
        tickerType: Int,
        actionBottomSheet: PdpDataTickerMessage
    ) {
        self.title = title
        self.message = message
        self.color = color
        self.link = link
        self.action = action
        self.actionLink = actionLink
        self.tickerType = tickerType
        self.actionBottomSheet = actionBottomSheet
    }
}

extension PdpDataTicker {
    private enum CodingKeys: String, CodingKey {
        case title, message, color, link, action, actionLink, tickerType, actionBottomSheet
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        message = try container.decode(String.self, forKey: .message)
        color = try container.decodeIfPresent(String.self, forKey: .color).flatMap(PdpDataTickerColor.init) ?? .info
        link = try container.decode(String.self, forKey: .link)
        let actionString = try container.decodeIfPresent(String.self, forKey: .action) ?? ""
        action = PdpDataTickerAction(rawValue: actionString)
        actionLink = try container.decode(String.self, forKey: .actionLink)
        tickerType = try container.decode(Int.self, forKey: .tickerType)
        actionBottomSheet = try container.decode(PdpDataTickerMessage.self, forKey: .actionBottomSheet)
    }
}

public enum PdpDataTickerAction: String, Equatable {
    case applink
    case bottomSheet = "bottomsheet"
}

public enum PdpDataTickerColor: String, Equatable {
    case info
    case warning
    case tips
}

public struct PdpDataTickerMessage: Equatable, Decodable {
    public var title: String
    public var message: String
    public var reason: String
    public var buttonText: String
    public var buttonLink: String?

    public init(title: String, message: String, reason: String, buttonText: String, buttonLink: String? = nil) {
        self.title = title
        self.message = message
        self.reason = reason
        self.buttonText = buttonText
        self.buttonLink = buttonLink
    }
}


internal struct PDPShopInfo: Decodable, Equatable {
    internal let favoriteData: PDPFavoriteData
    internal let shopAssets: ShopAssets
    internal let shopCore: ShopCore
    internal let location: String
    internal let statusInfo: StatusInfo
    internal let shopLastActive: String
    internal let activeProduct: String
    internal let createInfo: CreateInfo
    internal let shopStats: ShopStats
    internal let closedInfo: ClosedInfo
    internal let shopTier: PdpShopTier
    internal let badgeURL: String
    internal let tickerData: [PdpDataTicker]
    internal let shopMultilocation: ShopMultilocation
    internal let partnerLabel: String

    private enum CodingKeys: String, CodingKey {
        case favoriteData, shopAssets, shopCore, location, statusInfo, shopLastActive, activeProduct, createInfo, shopStats, closedInfo, shopTier, badgeURL, tickerData, shopMultilocation, partnerLabel
    }

    internal init(
        favoriteData: PDPFavoriteData,
        shopAssets: ShopAssets,
        shopCore: ShopCore,
        location: String,
        statusInfo: StatusInfo,
        shopLastActive: String,
        activeProduct: String,
        createInfo: CreateInfo,
        shopStats: ShopStats,
        closedInfo: ClosedInfo,
        shopTier: PdpShopTier,
        badgeURL: String,
        tickerData: [PdpDataTicker],
        shopMultilocation: ShopMultilocation,
        partnerLabel: String
    ) {
        self.favoriteData = favoriteData
        self.shopAssets = shopAssets
        self.shopCore = shopCore
        self.location = location
        self.statusInfo = statusInfo
        self.shopLastActive = shopLastActive
        self.activeProduct = activeProduct
        self.createInfo = createInfo
        self.shopStats = shopStats
        self.closedInfo = closedInfo
        self.shopTier = shopTier
        self.badgeURL = badgeURL
        self.tickerData = tickerData
        self.shopMultilocation = shopMultilocation
        self.partnerLabel = partnerLabel
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        favoriteData = try container.decode(PDPFavoriteData.self, forKey: .favoriteData)
        shopAssets = try container.decode(ShopAssets.self, forKey: .shopAssets)
        shopCore = try container.decode(ShopCore.self, forKey: .shopCore)
        location = try container.decode(String.self, forKey: .location)
        statusInfo = try container.decode(StatusInfo.self, forKey: .statusInfo)
        shopLastActive = try container.decode(String.self, forKey: .shopLastActive)
        activeProduct = try container.decode(String.self, forKey: .activeProduct)
        createInfo = try container.decode(CreateInfo.self, forKey: .createInfo)
        shopStats = try container.decode(ShopStats.self, forKey: .shopStats)
        closedInfo = try container.decode(ClosedInfo.self, forKey: .closedInfo)
        shopTier = try container.decodeIfPresent(Int.self, forKey: .shopTier).flatMap(PdpShopTier.init) ?? .regularMerchant
        badgeURL = try container.decode(String.self, forKey: .badgeURL)
        tickerData = try container.decode([PdpDataTicker].self, forKey: .tickerData)
        shopMultilocation = try container.decode(ShopMultilocation.self, forKey: .shopMultilocation)
        partnerLabel = try container.decode(String.self, forKey: .partnerLabel)
    }
}

internal struct ClosedInfo: Decodable, Equatable {
    internal let closedNote, reason, until: String
    internal let detail: Detail
}

internal struct Detail: Decodable, Equatable {
    internal let openDateUTC: String
}

internal struct CreateInfo: Decodable, Equatable {
    internal let shopCreated, epochShopCreatedUTC, openSince: String
}

internal struct PDPFavoriteData: Decodable, Equatable {
    internal let alreadyFavorited: Bool

    internal init(alreadyFavorited: Bool) {
        self.alreadyFavorited = alreadyFavorited
    }

    private enum CodingKeys: String, CodingKey {
        case alreadyFavorited
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let isFavorited = try container.decodeIfPresent(Int.self, forKey: .alreadyFavorited) ?? 0
        alreadyFavorited = isFavorited == 1
    }
}

internal struct ShopAssets: Decodable, Equatable {
    internal let avatar, cover: String
}

internal struct ShopCore: Decodable, Equatable {
    internal let shopID, domain, name, shopCoreDescription: String
    internal let ownerID, tagLine: String
    internal let url: String
    internal let defaultSort: Int

    private enum CodingKeys: String, CodingKey {
        case shopID, domain, name
        case shopCoreDescription = "description"
        case ownerID, tagLine, url, defaultSort
    }
}

internal struct ShopStats: Decodable, Equatable {
    internal let productSold, totalTx, totalShowcase: String
}

public enum PDPShopStatusType: Int {
    case deleted = 0
    case open = 1
    case closed = 2
    case moderated = 3
    case inactive = 4
    case moderatedPermanently = 5
    case incubated = 6
    case incomplete = 7
}


internal struct StatusInfo: Decodable, Equatable {
    internal let shopStatus: PDPShopStatusType
    internal var statusMessage, statusTitle: String
    internal let isIdle: Bool

    internal init(shopStatus: PDPShopStatusType, statusMessage: String, statusTitle: String, isIdle: Bool) {
        self.shopStatus = shopStatus
        self.statusMessage = statusMessage
        self.statusTitle = statusTitle
        self.isIdle = isIdle
    }

    private enum CodingKeys: String, CodingKey {
        case shopStatus, statusMessage, statusTitle, isIdle
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shopStatus = try container.decodeIfPresent(Int.self, forKey: .shopStatus).flatMap(PDPShopStatusType.init) ?? .closed
        statusMessage = try container.decodeIfPresent(String.self, forKey: .statusMessage) ?? ""
        statusTitle = try container.decodeIfPresent(String.self, forKey: .statusTitle) ?? ""
        isIdle = try container.decodeIfPresent(Bool.self, forKey: .isIdle) ?? false
    }
}

internal struct ShopMultilocation: Decodable, Equatable {
    internal let warehouseCount: String
    internal var eduAppLink: String?

    private enum CodingKeys: String, CodingKey {
        case warehouseCount
        case eduLink
    }

    private enum EduLinkCodingKeys: String, CodingKey {
        case appLink
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        warehouseCount = try container.decode(String.self, forKey: .warehouseCount)

        let eduLinkContainer = try container.nestedContainer(keyedBy: EduLinkCodingKeys.self, forKey: .eduLink)
        eduAppLink = try eduLinkContainer.decode(String.self, forKey: .appLink)
    }

    public init(warehouseCount: String,
                eduAppLink: String) {
        self.warehouseCount = warehouseCount
        self.eduAppLink = eduAppLink.isEmpty ? nil : eduAppLink
    }
}

internal enum PdpShopTier: Int, Encodable {
    case regularMerchant = 0
    case powerMerchant = 1
    case officialStore = 2
    case powerMerchantPro = 3

    internal var accessibilityLabel: String {
        switch self {
        case .officialStore:
            return "officialStore"
        case .regularMerchant:
            return "regular merchant"
        case .powerMerchant:
            return "power merchant"
        case .powerMerchantPro:
            return "power merchant pro"
        }
    }
}

public struct ShopCouponResponse: Equatable {
    public var vouchers: [ShopCoupon]
    public var errorTitle: String?
    public var errorMessage: String?

    public init(vouchers: [ShopCoupon], errorTitle: String?, errorMessage: String?) {
        self.vouchers = vouchers
        self.errorTitle = errorTitle
        self.errorMessage = errorMessage
    }
}

extension ShopCouponResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case vouchers
        case errorTitle = "error_message_title"
        case errorMessage = "error_message"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let vouchers = try container.decodeIfPresent([ShopCoupon].self, forKey: .vouchers)
        let errorTitle = try container.decodeIfPresent(String.self, forKey: .errorTitle)
        let errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)

        self.init(vouchers: vouchers ?? [], errorTitle: errorTitle, errorMessage: errorMessage)
    }
}

public struct ShopCoupon: Decodable, Equatable {
    public let id: Int
    public let name: String
    public let code: String
    public let type: CouponType?
    public let amount: CouponAmount?
    public let minimumSpend: Int
    public let owner: CouponOwner?
    public let validThru: String
    public let tnc: String
    public let banner: CouponBanner?
    public let status: CouponStatus?
    public let restrictedForLiquid: Bool
    public let isLockToProduct: Bool

    private enum CodingKeys: String, CodingKey {
        case id = "voucher_id"
        case name = "voucher_name"
        case code = "voucher_code"
        case type = "voucher_type"
        case amount
        case minimumSpend = "minimum_spend"
        case owner
        case validThru = "valid_thru"
        case tnc
        case banner
        case status
        case restrictedForLiquid = "restricted_for_liquid_product"
        case isLockToProduct
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        code = try container.decode(String.self, forKey: .code)
        type = try container.decodeIfPresent(CouponType.self, forKey: .type)
        amount = try container.decodeIfPresent(CouponAmount.self, forKey: .amount)
        minimumSpend = try container.decode(Int.self, forKey: .minimumSpend)
        owner = try container.decodeIfPresent(CouponOwner.self, forKey: .owner)
        validThru = try container.decode(String.self, forKey: .validThru)
        tnc = try container.decode(String.self, forKey: .tnc)
        banner = try container.decodeIfPresent(CouponBanner.self, forKey: .banner)
        status = try container.decodeIfPresent(CouponStatus.self, forKey: .status)
        restrictedForLiquid = try container.decodeIfPresent(Bool.self, forKey: .restrictedForLiquid) ?? false
        isLockToProduct = try container.decodeIfPresent(Bool.self, forKey: .isLockToProduct) ?? false
    }

    public init(id: Int, name: String, code: String, type: CouponType?, amount: CouponAmount?, minimumSpend: Int, owner: CouponOwner?, validThru: String, tnc: String, banner: CouponBanner?, status: CouponStatus?, restrictedForLiquid: Bool, isLockToProduct: Bool) {
        self.id = id
        self.name = name
        self.code = code
        self.type = type
        self.amount = amount
        self.minimumSpend = minimumSpend
        self.owner = owner
        self.validThru = validThru
        self.tnc = tnc
        self.banner = banner
        self.status = status
        self.restrictedForLiquid = restrictedForLiquid
        self.isLockToProduct = isLockToProduct
    }
}

public struct CouponType: Decodable, Equatable {
    public let voucherType: Int

    private enum CodingKeys: String, CodingKey {
        case voucherType = "voucher_type"
    }

    public init(voucherType: Int) {
        self.voucherType = voucherType
    }
}

public struct CouponAmount: Decodable, Equatable {
    public let type: Int
    public let amount: Double

    private enum CodingKeys: String, CodingKey {
        case type = "amount_type"
        case amount
    }

    public init(type: Int, amount: Double) {
        self.type = type
        self.amount = amount
    }
}

public struct CouponOwner: Decodable, Equatable {
    public let id: Int

    private enum CodingKeys: String, CodingKey {
        case id = "owner_id"
    }

    public init(id: Int) {
        self.id = id
    }
}

public struct CouponBanner: Decodable, Equatable {
    public let mobileUrl: String

    private enum CodingKeys: String, CodingKey {
        case mobileUrl = "mobile_url"
    }

    public init(mobileUrl: String) {
        self.mobileUrl = mobileUrl
    }
}

public struct CouponStatus: Decodable, Equatable {
    public let status: Int

    public init(status: Int) {
        self.status = status
    }
}

public struct RestrictionInfo: Decodable, Equatable {
    public let message: String?
    public let restrictionData: [RestrictionData]

    private enum CodingKeys: String, CodingKey {
        case restrictionData, message
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let restrictData = try container.decodeIfPresent([RestrictionData].self, forKey: .restrictionData) ?? []
        restrictionData = restrictData
        let message = try container.decodeIfPresent(String.self, forKey: .message)
        self.message = message
    }

    public init(restrictionData: [RestrictionData], message: String?) {
        self.restrictionData = restrictionData
        self.message = message
    }
}

public struct RestrictionData: Decodable, Equatable {
    public let productID: String?
    public let isEligible: Bool
    public let action: PDPRestrictionAction?

    private enum CodingKeys: String, CodingKey {
        case isEligible
        case action, productID
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isEligible = try container.decode(Bool.self, forKey: .isEligible)
        let actions = try container.decodeIfPresent([PDPRestrictionAction].self, forKey: .action) ?? []
        action = actions.first
        productID = try container.decodeIfPresent(String.self, forKey: .productID)
    }

    public init(isEligible: Bool, action: PDPRestrictionAction?, productID: String?) {
        self.isEligible = isEligible
        self.action = action
        self.productID = productID
    }
}

public enum PdpRestrictionAttribute: String, Decodable {
    case exclusiveDiscount = "exclusive_discount",
        shopFollower = "shop_follower",
        blockedByKYCStatus = "category_user_kyc_status",
        blockedByAge = "category_user_kyc_age",
        blockedGamification = "gamification_eligible_rp0",
        blockedByCampaignLocation = "campaign_location"
}

public struct PDPRestrictionAction: Decodable, Equatable {
    public let title: String
    public let description: String
    public let badgeURL: String?
    public let actionType: String
    public let buttonText: String
    public var buttonLink: String?
    public var attributeName: PdpRestrictionAttribute?

    public init(
        title: String,
        description: String,
        badgeURL: String?,
        actionType: String,
        buttonText: String,
        buttonLink: String?,
        attributeName: PdpRestrictionAttribute?
    ) {
        self.title = title
        self.description = description
        self.badgeURL = badgeURL
        self.actionType = actionType
        self.buttonText = buttonText
        self.buttonLink = buttonLink
        self.attributeName = attributeName
    }
}

extension PDPRestrictionAction {
    public var badgeUrlFromAttributeName: String {
        switch attributeName {
        case .exclusiveDiscount, .blockedByAge, .blockedByKYCStatus, .blockedByCampaignLocation: return badgeURL ?? ""
        case .shopFollower, .blockedGamification, .none: return ""
        }
    }
}


public struct AlternateDecodingContext {
    public let usingAlternateKeys: Bool

    public init(usingAlternateKeys: Bool = false) {
        self.usingAlternateKeys = usingAlternateKeys
    }
}

private let contextKey = CodingUserInfoKey(rawValue: "alternateContext")!

extension JSONDecoder {
    public var context: AlternateDecodingContext? {
        get { return userInfo[contextKey] as? AlternateDecodingContext }
        set { userInfo[contextKey] = newValue }
    }
}

extension Decoder {
    public var context: AlternateDecodingContext? {
        return userInfo[contextKey] as? AlternateDecodingContext
    }
}


public struct TokopointsCatalogMVCSummaryResponse: Decodable, Equatable {
    public var diffIdentifier: String {
        return "TokopointsCatalogMVCSummary"
    }

    public let resultStatus: ResultStatus?
    public let isShown: Bool
    public let animatedInfos: [TokopointsCatalogMVCSummaryAnimatedInfos]

    public init(resultStatus: ResultStatus?,
                isShown: Bool,
                animatedInfos: [TokopointsCatalogMVCSummaryAnimatedInfos]) {
        self.resultStatus = resultStatus
        self.isShown = isShown
        self.animatedInfos = animatedInfos
    }

    private enum CodingKeys: String, CodingKey {
        case resultStatus
        case isShown
        // Somehow different query with same value having a different field key
        /**
         merchantVoucherSummary = animatedInfo
         tokopointsCatalogMVCSummary = animatedInfos
         */
        case animatedInfos
        case animatedInfo
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        resultStatus = try container.decodeIfPresent(ResultStatus.self, forKey: .resultStatus)
        isShown = try container.decode(Bool.self, forKey: .isShown)

        if let context = decoder.context, context.usingAlternateKeys {
            animatedInfos = try container.decode([TokopointsCatalogMVCSummaryAnimatedInfos].self, forKey: .animatedInfo)
        } else {
            animatedInfos = try container.decode([TokopointsCatalogMVCSummaryAnimatedInfos].self, forKey: .animatedInfos)
        }
    }
}

public struct ResultStatus: Decodable, Equatable {
    public let code: String
    public let status: String?
    public let message: [String]
    public let reason: String?

    public init(
        code: String,
        status: String?,
        message: [String],
        reason: String?
    ) {
        self.code = code
        self.status = status
        self.message = message
        self.reason = reason
    }
}

public struct TokopointsCatalogMVCSummaryAnimatedInfos: Decodable, Equatable {
    public let title: String
    public let subTitle: String
    public let iconURL: String

    public init(title: String,
                subTitle: String,
                iconURL: String) {
        self.title = title
        self.subTitle = subTitle
        self.iconURL = iconURL
    }
}

public struct GlobalRatesEstimate: Equatable, Decodable {
    public var data: RatesEstimateData
    public var warehouseID: String
    public var products: [String]
    public var bottomsheet: RatesErrorBottomSheet
    public var boMetadata: String
    public var productMetadata: [ProductMetaData]

    public init(data: RatesEstimateData, warehouseID: String, products: [String], bottomsheet: RatesErrorBottomSheet, boMetadata: String, productMetadata: [ProductMetaData]) {
        self.data = data
        self.warehouseID = warehouseID
        self.products = products
        self.bottomsheet = bottomsheet
        self.boMetadata = boMetadata
        self.productMetadata = productMetadata
    }
}

public struct RatesEstimateData: Equatable, Decodable {
    public var errors: [RatesGeneralError]?
    public var isSupportInstantCourier: Bool
    public var destination, subtitle, title, eTAText: String
    public var cheapestShippingPrice: Int
    public var totalService: Int
    public var icon: String
    public var shippingCtxDesc: String
    public var originalShippingRate: Int
    public var hasUsedBenefit: Bool
    public var chipsLabel: [String]
    public var fulfillmentData: GlobalfulfillmentData
    public var tickers: [PdpDataTicker]
    public var isScheduled: Bool
    public var boBadge: RatesBOImage

    public init(
        errors: [RatesGeneralError]? = nil,
        isSupportInstantCourier: Bool,
        destination: String,
        subtitle: String,
        title: String,
        eTAText: String,
        cheapestShippingPrice: Int,
        totalService: Int,
        icon: String,
        shippingCtxDesc: String,
        originalShippingRate: Int,
        hasUsedBenefit: Bool,
        chipsLabel: [String],
        fulfillmentData: GlobalfulfillmentData,
        tickers: [PdpDataTicker] = [],
        isScheduled: Bool,
        boBadge: RatesBOImage
    ) {
        self.errors = errors
        self.isSupportInstantCourier = isSupportInstantCourier
        self.destination = destination
        self.subtitle = subtitle
        self.title = title
        self.eTAText = eTAText
        self.cheapestShippingPrice = cheapestShippingPrice
        self.totalService = totalService
        self.icon = icon
        self.shippingCtxDesc = shippingCtxDesc
        self.originalShippingRate = originalShippingRate
        self.hasUsedBenefit = hasUsedBenefit
        self.chipsLabel = chipsLabel
        self.fulfillmentData = fulfillmentData
        self.tickers = tickers
        self.isScheduled = isScheduled
        self.boBadge = boBadge
    }
}

public struct RatesGeneralError: Equatable, Decodable {
    public var code: RatesEstimateErrorCode
    public var message: String

    public init(code: RatesEstimateErrorCode, message: String) {
        self.code = code
        self.message = message
    }

    private enum CodingKeys: String, CodingKey {
        case code = "Code"
        case message = "Message"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        let codeError = try container.decodeIfPresent(Int.self, forKey: .code) ?? 0
        switch codeError {
        case 50502, 50504:
            code = .outOfCoverage
        case 50501:
            code = .noPinPoint
        case 50503:
            code = .overWeight
        default:
            code = .unclassifiedError
        }
    }
}

public enum RatesEstimateErrorCode: Equatable {
    case outOfCoverage
    case unclassifiedError
    case noPinPoint
    case overWeight
}

public struct RatesErrorBottomSheet: Equatable, Decodable, Hashable {
    public var title: String
    public var iconURL: String
    public var subtitle: String
    public var buttonCopy: String

    public init(title: String, iconURL: String, subtitle: String, buttonCopy: String) {
        self.title = title
        self.iconURL = iconURL
        self.subtitle = subtitle
        self.buttonCopy = buttonCopy
    }
}

public struct GlobalfulfillmentData: Equatable, Decodable {
    public var icon: String
    public var prefix: String
    public var description: String

    public init(icon: String, prefix: String, description: String) {
        self.icon = icon
        self.prefix = prefix
        self.description = description
    }
}

public struct ProductMetaData: Equatable, Decodable {
    public var productID: String
    public var value: String

    public init(productID: String, value: String) {
        self.productID = productID
        self.value = value
    }
}

public struct RatesBOImage: Equatable, Decodable {
    public var imageURL: String
    public var isUsingPadding: Bool
    public var imageHeight: Int

    public init(imageURL: String, isUsingPadding: Bool, imageHeight: Int) {
        self.imageURL = imageURL
        self.isUsingPadding = isUsingPadding
        self.imageHeight = imageHeight
    }
}

internal enum ProductBundlingType: String, Equatable {
    case single
    case multiple
}

internal struct PDPProductBundlingData: Decodable, Equatable {
    internal let bundleId: String
    internal let bundleType: ProductBundlingType
    internal let bundleName: String
    internal let titleComponent: String
    internal let parentString: String
    internal let bundlingFinalPrice: String
    internal let bundlingOriginalPrice: String
    internal let bundlingSavedPrice: String
    internal let bundlePreOrderText: String
    internal let bundleItems: [PDPProductBundlingItem]

    private enum CodingKeys: String, CodingKey {
        case bundleID, type, name, titleComponent, productID, finalPriceBundling, originalPriceBundling, savingPriceBundling, preorderString, bundleItems
    }

    internal init(
        bundleId: String, bundleType: ProductBundlingType, bundleName: String,
        titleComponent: String, parentString: String, bundlingFinalPrice: String,
        bundlingOriginalPrice: String, bundlingSavedPrice: String, bundlePreOrderText: String,
        bundleItems: [PDPProductBundlingItem]
    ) {
        self.bundleId = bundleId
        self.bundleType = bundleType
        self.bundleName = bundleName
        self.titleComponent = titleComponent
        self.parentString = parentString
        self.bundlingFinalPrice = bundlingFinalPrice
        self.bundlingOriginalPrice = bundlingOriginalPrice
        self.bundlingSavedPrice = bundlingSavedPrice
        self.bundlePreOrderText = bundlePreOrderText
        self.bundleItems = bundleItems
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        bundleId = try container.decode(String.self, forKey: .bundleID)
        let rawBundleType = try container.decode(String.self, forKey: .type)
        bundleType = ProductBundlingType(rawValue: rawBundleType.lowercased()) ?? .single
        bundleName = try container.decode(String.self, forKey: .name)
        titleComponent = try container.decode(String.self, forKey: .titleComponent)
        let rawString = try container.decode(String.self, forKey: .productID)
        parentString = rawString
        bundlingFinalPrice = try container.decode(String.self, forKey: .finalPriceBundling)
        bundlingOriginalPrice = try container.decode(String.self, forKey: .originalPriceBundling)
        bundlingSavedPrice = try container.decode(String.self, forKey: .savingPriceBundling)
        bundlePreOrderText = try container.decode(String.self, forKey: .preorderString)
        bundleItems = try container.decode([PDPProductBundlingItem].self, forKey: .bundleItems)
    }
}

internal struct PDPProductBundlingItem: Decodable, Equatable {
    internal let itemProductId: String
    internal let productName: String
    internal let productImageURL: String
    internal let productQty: String
    internal let productOriginalPrice: String
    internal let bundledProductPrice: String
    internal let discountPercentage: String

    private enum CodingKeys: String, CodingKey {
        case productID, name, picURL, quantity, originalPrice, bundlePrice, discountPercentage
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let rawString = try container.decode(String.self, forKey: .productID)
        itemProductId = rawString
        productName = try container.decode(String.self, forKey: .name)
        productImageURL = try container.decode(String.self, forKey: .picURL)
        productQty = try container.decode(String.self, forKey: .quantity)
        productOriginalPrice = try container.decode(String.self, forKey: .originalPrice)
        bundledProductPrice = try container.decode(String.self, forKey: .bundlePrice)
        discountPercentage = try container.decode(String.self, forKey: .discountPercentage)
    }

    internal init(itemProductId: String, productName: String, productImageURL: String, productQty: String, productOriginalPrice: String, bundledProductPrice: String, discountPercentage: String) {
        self.itemProductId = itemProductId
        self.productName = productName
        self.productImageURL = productImageURL
        self.productQty = productQty
        self.productOriginalPrice = productOriginalPrice
        self.bundledProductPrice = bundledProductPrice
        self.discountPercentage = discountPercentage
    }
}

internal struct PdpGlobalBundlingData: Equatable, Decodable {
    internal let title: String
    internal let widgetType: Int
    internal let productId: String
    internal let whId: String

    private enum CodingKeys: String, CodingKey {
        case title, widgetType
        case productId = "productID"
        case whId = "whID"
    }
}

internal struct PdpCategoryCarousel: Equatable, Decodable {
    internal let titleCarousel: String
    internal let linkText: String
    internal let applink: String
    internal let list: [PdpCategoryCarouselData]
}

internal struct PdpCategoryCarouselData: Equatable, Decodable {
    internal let icon: String
    internal let title: String
    internal let isApplink: Bool
    internal let applink: String
    internal let categoryID: String
}

internal struct PdpAugmentedRealityData: Equatable, Decodable {
    internal let imageUrl: String
    internal let message: String
    internal var applink: String
    internal let productIDs: [String]
}

internal enum PdpCustomInfoTitleStatus: String, Equatable {
    case show
    case hide
    case placeholder
}

internal struct PdpCustomInfoTitleData: Equatable, Decodable {
    internal let title: String
    internal let status: PdpCustomInfoTitleStatus
    internal let componentName: String

    internal init(title: String, status: PdpCustomInfoTitleStatus, componentName: String) {
        self.title = title
        self.status = status
        self.componentName = componentName
    }

    private enum CodingKeys: String, CodingKey {
        case title
        case status
        case componentName
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decode(String.self, forKey: .title)
        status = try container.decodeIfPresent(String.self, forKey: .status).flatMap(PdpCustomInfoTitleStatus.init) ?? .hide
        componentName = try container.decode(String.self, forKey: .componentName)
    }
}

internal struct PdpDataTickerInfo: Equatable, Decodable {
    internal var productIDs: [String]
    internal var tickerData: [PdpDataTicker]
}


internal struct PdpNavBarModel: Decodable, Equatable {
    internal let name: String
    internal let items: [PdpNavBarItem]
}

internal struct PdpNavBarItem: Decodable, Equatable {
    internal let title: String
    internal let componentName: String
}

internal struct ShopAdditional: Decodable, Equatable {
    internal let icon: String
    internal let title: String
    internal let linkText: String
    internal let subtitle: String
    internal let label: [String]
}

internal struct PrescriptionDrug: Decodable, Equatable {
    internal var applink: String
    internal var subtitle: String
}

// GQL PDP GetData
// Docs : https://tokopedia.atlassian.net/wiki/spaces/PDP/pages/830477099/PDP+P2+GQL+Query#GQL-Query
internal struct PDPSecondPriority: Decodable, Equatable {
    internal var reviewList: ReviewListData?
    internal var socialProofs: [SocialProofData]?
    internal var mostHelpFulReviewData: MostHelpfulReview?
    internal var ratingData: RatingData?
    internal var reviewImage: ReviewImagesList?
    internal let wishlistCount: String?
    internal var shopCommitment: ShopCommitmentResponse?
    internal var shopReputation: PDPShopReputation?
    internal var nearestWarehouse: [VariantWarehouseInfo]?
    internal let isOnWishlist: Bool?
    internal var upcomingCampaigns: [PDPDataUpcomingDeals]?
    internal var cartRedirection: CartRedirection?
    internal var shopChatSpeed: ShopChatSpeed?
    internal var shopFinishRate: String?
    internal var shopRating: ShopRating?
    internal var shopPackSpeed: ShopPackingSpeed?
    internal var validateTradeIn: TradeIn?
    internal var installmentCalculation: FtInstallmentCalculation?
    internal let pdpInsurenceData: PDPInsurenceModel?
    internal var installmentRecommendation: FtInstallmentRecommendation?
    internal var merchantVouchers: ShopCouponResponse?
    internal var shopInfo: PDPShopInfo?
    internal var restrictionInfo: RestrictionInfo?
    internal var merchantVoucherSummary: TokopointsCatalogMVCSummaryResponse?
    internal var ratesEstimate: [GlobalRatesEstimate]?
    internal var bebasOngkir: PdpBebasOngkir?
    internal var uniqueSellingPoint: PdpUniqueSellingPoint?
    internal var bundleInfo: [PDPProductBundlingData]?
    internal var ticker: [PdpDataTickerInfo]?
    internal var augmentedReality: PdpAugmentedRealityData?
    internal var navBar: PdpNavBarModel?
    internal var shopAdditional: ShopAdditional?
    internal var prescriptionDrug: PrescriptionDrug?
    internal var customInfoTitles: [PdpCustomInfoTitleData]

    internal init(
        reviewList: ReviewListData?,
        socialProofs: [SocialProofData]?,
        wishlistCount: String,
        ratingData: RatingData?,
        shopCommitment: ShopCommitmentResponse?,
        shopReputation: PDPShopReputation?,
        nearestWarehouse: [VariantWarehouseInfo]?,
        isOnWishlist: Bool,
        upcomingCampaigns: [PDPDataUpcomingDeals]?,
        cartRedirection: CartRedirection?,
        shopChatSpeed: ShopChatSpeed?,
        shopFinishRate: String?,
        shopRating: ShopRating?,
        shopPackSpeed: ShopPackingSpeed?,
        validateTradeIn: TradeIn?,
        installmentCalculation: FtInstallmentCalculation?,
        pdpInsurenceData: PDPInsurenceModel?,
        installmentRecommendation: FtInstallmentRecommendation?,
        merchantVouchers: ShopCouponResponse?,
        shopInfo: PDPShopInfo?,
        restrictionInfo: RestrictionInfo?,
        merchantVoucherSummary: TokopointsCatalogMVCSummaryResponse?,
        ratesEstimate: [GlobalRatesEstimate]?,
        bebasOngkir: PdpBebasOngkir?,
        uniqueSellingPoint: PdpUniqueSellingPoint?,
        reviewImage: ReviewImagesList?,
        mostHelpFulReviewData: MostHelpfulReview?,
        bundleInfo: [PDPProductBundlingData]?,
        ticker: [PdpDataTickerInfo]?,
        navBar: PdpNavBarModel?,
        shopAdditional: ShopAdditional?,
        augmentedReality: PdpAugmentedRealityData?,
        prescriptionDrug: PrescriptionDrug?,
        customInfoTitles: [PdpCustomInfoTitleData] = []
    ) {
        self.reviewList = reviewList
        self.socialProofs = socialProofs
        self.wishlistCount = wishlistCount
        self.ratingData = ratingData
        self.shopCommitment = shopCommitment
        self.shopReputation = shopReputation
        self.nearestWarehouse = nearestWarehouse
        self.mostHelpFulReviewData = mostHelpFulReviewData
        self.reviewImage = reviewImage
        self.isOnWishlist = isOnWishlist
        self.upcomingCampaigns = upcomingCampaigns
        self.cartRedirection = cartRedirection
        self.shopChatSpeed = shopChatSpeed
        self.shopFinishRate = shopFinishRate
        self.shopRating = shopRating
        self.shopPackSpeed = shopPackSpeed
        self.validateTradeIn = validateTradeIn
        self.installmentCalculation = installmentCalculation
        self.pdpInsurenceData = pdpInsurenceData
        self.installmentRecommendation = installmentRecommendation
        self.merchantVouchers = merchantVouchers
        self.shopInfo = shopInfo
        self.restrictionInfo = restrictionInfo
        self.merchantVoucherSummary = merchantVoucherSummary
        self.ratesEstimate = ratesEstimate
        self.bebasOngkir = bebasOngkir
        self.uniqueSellingPoint = uniqueSellingPoint
        self.bundleInfo = bundleInfo
        self.ticker = ticker
        self.augmentedReality = augmentedReality
        self.navBar = navBar
        self.shopAdditional = shopAdditional
        self.prescriptionDrug = prescriptionDrug
        self.customInfoTitles = customInfoTitles
    }

    private enum CodingKeys: String, CodingKey {
        case reviewList
        case socialProofs = "socialProofComponent"
        case mostHelpFulReviewData
        case reviewImage
        case ratingData = "rating"
        case wishlistCount
        case shopCommitment
        case shopReputation = "reputationShop"
        case nearestWarehouse
        case isOnWishlist = "productWishlistQuery"
        case isGoApotik = "shopFeature"
        case upcomingCampaigns
        case cartRedirection
        case shopChatSpeed = "shopTopChatSpeed"
        case shopFinishRate
        case shopRating = "shopRatingsQuery"
        case shopPackSpeed
        case validateTradeIn
        case installmentRecommendation
        case installmentCalculation
        case merchantVouchers = "merchantVoucher"
        case shopInfo
        case restrictionInfo
        case pdpInsurenceData = "ppGetItemDetailPage"
        case merchantVoucherSummary
        case ratesEstimate
        case bebasOngkir
        case uniqueSellingPoint
        case bundleInfo
        case ticker
        case augmentedReality = "arInfo"
        case navBar
        case shopAdditional
        case prescriptionDrug = "obatKeras"
        case customInfoTitle
    }

    private enum WishlistCodingKeys: String, CodingKey {
        case value
    }

    private enum TickerCodingKeys: String, CodingKey {
        case tickerInfo
    }

    private enum ShopFinishRateCodingKeys: String, CodingKey {
        case finishRate
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reviewList = try container.decodeIfPresent(ReviewListData.self, forKey: .reviewList)
        socialProofs = try container.decodeIfPresent([SocialProofData].self, forKey: .socialProofs)
        wishlistCount = try container.decodeIfPresent(String.self, forKey: .wishlistCount) ?? ""
        mostHelpFulReviewData = try container.decodeIfPresent(MostHelpfulReview.self, forKey: .mostHelpFulReviewData)
        ratingData = try container.decodeIfPresent(RatingData.self, forKey: .ratingData)
        reviewImage = try container.decodeIfPresent(ReviewImagesList.self, forKey: .reviewImage)
        shopCommitment = try container.decodeIfPresent(ShopCommitmentResponse.self, forKey: .shopCommitment)
        shopReputation = try container.decodeIfPresent(PDPShopReputation.self, forKey: .shopReputation)
        nearestWarehouse = try container.decodeIfPresent([VariantWarehouseInfo].self, forKey: .nearestWarehouse)
        let wishlistData = try container.nestedContainer(keyedBy: WishlistCodingKeys.self, forKey: .isOnWishlist)
        isOnWishlist = try wishlistData.decodeIfPresent(Bool.self, forKey: .value) ?? false
        upcomingCampaigns = try container.decodeIfPresent([PDPDataUpcomingDeals].self, forKey: .upcomingCampaigns)
        cartRedirection = try container.decodeIfPresent(CartRedirection.self, forKey: .cartRedirection)
        shopChatSpeed = try container.decodeIfPresent(ShopChatSpeed.self, forKey: .shopChatSpeed)
        let shopFinishRateContainer = try container.nestedContainer(keyedBy: ShopFinishRateCodingKeys.self, forKey: .shopFinishRate)
        shopFinishRate = try shopFinishRateContainer.decodeIfPresent(String.self, forKey: .finishRate)
        shopRating = try container.decodeIfPresent(ShopRating.self, forKey: .shopRating)
        shopPackSpeed = try container.decodeIfPresent(ShopPackingSpeed.self, forKey: .shopPackSpeed)
        validateTradeIn = try container.decodeIfPresent(TradeIn.self, forKey: .validateTradeIn)
        installmentCalculation = try container.decodeIfPresent(FtInstallmentCalculation.self, forKey: .installmentCalculation)
        installmentRecommendation = try container.decodeIfPresent(FtInstallmentRecommendation.self, forKey: .installmentRecommendation)
        merchantVouchers = try container.decodeIfPresent(ShopCouponResponse.self, forKey: .merchantVouchers)
        shopInfo = try container.decodeIfPresent(PDPShopInfo.self, forKey: .shopInfo)
        restrictionInfo = try container.decodeIfPresent(RestrictionInfo.self, forKey: .restrictionInfo)
        pdpInsurenceData = try container.decodeIfPresent(PDPInsurenceModel.self, forKey: .pdpInsurenceData)
        merchantVoucherSummary = try container.decodeIfPresent(TokopointsCatalogMVCSummaryResponse.self, forKey: .merchantVoucherSummary)
        ratesEstimate = try container.decodeIfPresent([GlobalRatesEstimate].self, forKey: .ratesEstimate)
        bebasOngkir = try container.decodeIfPresent(PdpBebasOngkir.self, forKey: .bebasOngkir)
        uniqueSellingPoint = try container.decodeIfPresent(PdpUniqueSellingPoint.self, forKey: .uniqueSellingPoint)
        bundleInfo = try container.decodeIfPresent([PDPProductBundlingData].self, forKey: .bundleInfo)
        let tickerData = try container.nestedContainer(keyedBy: TickerCodingKeys.self, forKey: .ticker)
        ticker = try tickerData.decodeIfPresent([PdpDataTickerInfo].self, forKey: .tickerInfo)
        augmentedReality = try container.decodeIfPresent(PdpAugmentedRealityData.self, forKey: .augmentedReality)
        navBar = try container.decodeIfPresent(PdpNavBarModel.self, forKey: .navBar)
        shopAdditional = try container.decodeIfPresent(ShopAdditional.self, forKey: .shopAdditional)
        prescriptionDrug = try container.decodeIfPresent(PrescriptionDrug.self, forKey: .prescriptionDrug)
        customInfoTitles = try container.decodeIfPresent([PdpCustomInfoTitleData].self, forKey: .customInfoTitle) ?? []
    }
}

