import 'json.dart';

T? _tryParse<T extends Enum>(
  List<T> values,
  String? raw,
  String Function(T value) wire,
) {
  if (raw == null || raw.isEmpty) return null;
  for (final value in values) {
    if (wire(value) == raw) return value;
  }
  throw FormatException('Valor desconocido: $raw');
}

/// Categorías de estado. Sin filtro, `statuses.list()` devuelve las cuatro.
enum StatusCategory {
  package,
  shipment,
  other,
  fleet;

  String get wire => name;

  static StatusCategory? tryParse(String? value) =>
      _tryParse(values, value, (item) => item.wire);
}

const statusCategories = <StatusCategory>[
  StatusCategory.package,
  StatusCategory.shipment,
  StatusCategory.other,
  StatusCategory.fleet,
];

/// Tipo de office. `office` atiende al cliente. `warehouse` es bodega.
enum OfficeType {
  office,
  warehouse;

  String get wire => name;

  static OfficeType? tryParse(String? value) =>
      _tryParse(values, value, (item) => item.wire);
}

const officeTypes = <OfficeType>[OfficeType.office, OfficeType.warehouse];

/// Tipo de cuenta. Personal exige `firstName`. Empresa exige `companyName`.
enum AccountType {
  personal('PERSONAL'),
  business('BUSINESS');

  const AccountType(this.wire);

  final String wire;

  static AccountType? tryParse(String? value) =>
      _tryParse(values, value, (item) => item.wire);
}

const accountTypes = <AccountType>[AccountType.personal, AccountType.business];

/// Roles de directorio. En un cliente el API solo persiste `CLIENT`.
enum CustomerType {
  client('CLIENT'),
  shipper('SHIPPER'),
  consignee('CONSIGNEE'),
  carrier('CARRIER'),
  forwarder('FORWARDER'),
  notifyParty('NOTIFY_PARTY'),
  broker('BROKER'),
  importer('IMPORTER'),
  exporter('EXPORTER'),
  agent('AGENT'),
  warehouse('WAREHOUSE');

  const CustomerType(this.wire);

  final String wire;

  static CustomerType parse(String value) {
    final parsed = tryParse(value);
    if (parsed == null) {
      throw FormatException('Tipo de cliente desconocido: $value');
    }
    return parsed;
  }

  static CustomerType? tryParse(String? value) =>
      _tryParse(values, value, (item) => item.wire);
}

const customerTypes = <CustomerType>[
  CustomerType.client,
  CustomerType.shipper,
  CustomerType.consignee,
  CustomerType.carrier,
  CustomerType.forwarder,
  CustomerType.notifyParty,
  CustomerType.broker,
  CustomerType.importer,
  CustomerType.exporter,
  CustomerType.agent,
  CustomerType.warehouse,
];

/// Roles que se envían en `types` de un contacto. Nunca `CLIENT`.
enum ContactType {
  shipper('SHIPPER'),
  consignee('CONSIGNEE'),
  carrier('CARRIER'),
  forwarder('FORWARDER'),
  notifyParty('NOTIFY_PARTY'),
  broker('BROKER'),
  importer('IMPORTER'),
  exporter('EXPORTER'),
  agent('AGENT'),
  warehouse('WAREHOUSE');

  const ContactType(this.wire);

  final String wire;

  static ContactType parse(String value) {
    final parsed = tryParse(value);
    if (parsed == null) {
      throw FormatException('Tipo de contacto desconocido: $value');
    }
    return parsed;
  }

  static ContactType? tryParse(String? value) =>
      _tryParse(values, value, (item) => item.wire);
}

const contactTypes = <ContactType>[
  ContactType.shipper,
  ContactType.consignee,
  ContactType.carrier,
  ContactType.forwarder,
  ContactType.notifyParty,
  ContactType.broker,
  ContactType.importer,
  ContactType.exporter,
  ContactType.agent,
  ContactType.warehouse,
];

/// Prefijo interno del recibo. Hoy el único tipo es WR.
enum PackageType {
  wr('WR');

  const PackageType(this.wire);

  final String wire;

  static PackageType? tryParse(String? value) =>
      _tryParse(values, value, (item) => item.wire);
}

enum PhoneChannel {
  whatsapp,
  phone;

  String get wire => name;

  static PhoneChannel? tryParse(String? value) =>
      _tryParse(values, value, (item) => item.wire);
}

/// Orden de clientes y contactos.
enum DirectorySort {
  recent('recent'),
  oldest('oldest'),
  nameAsc('name-asc'),
  nameDesc('name-desc');

  const DirectorySort(this.wire);

  final String wire;
}

/// Organización autenticada por la API key. `GET /org-api/v1/organization`.
final class Organization {
  const Organization({
    required this.id,
    required this.name,
    required this.slug,
    required this.enterpriseCode,
    required this.countryCode,
    required this.currency,
    required this.organizationId,
  });

  final String id;
  final String name;
  final String slug;
  final String? enterpriseCode;
  final String countryCode;
  final String currency;
  final String? organizationId;

  factory Organization.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return Organization(
      id: map.string('id') ?? '',
      name: map.string('name') ?? '',
      slug: map.string('slug') ?? '',
      enterpriseCode: map.string('enterpriseCode'),
      countryCode: map.string('countryCode') ?? '',
      currency: map.string('currency') ?? '',
      organizationId: map.string('organizationId'),
    );
  }
}

/// Estado de paquete, envío, otro o flota. `label` es el nombre visible.
final class Status {
  const Status({
    required this.id,
    required this.label,
    required this.description,
    required this.position,
    required this.icon,
    required this.category,
    required this.isActive,
    required this.isVisible,
    required this.isHiddenFromClient,
    required this.warehouseId,
    required this.locationId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String label;
  final String description;
  final int position;
  final String icon;
  final StatusCategory category;
  final bool isActive;
  final bool isVisible;
  final bool isHiddenFromClient;
  final String? warehouseId;
  final String? locationId;
  final String? createdAt;
  final String? updatedAt;

  factory Status.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return Status(
      id: map.string('id') ?? '',
      label: map.string('label') ?? '',
      description: map.string('description') ?? '',
      position: map.integer('position'),
      icon: map.string('icon') ?? '',
      category: StatusCategory.tryParse(map.string('category')) ??
          StatusCategory.package,
      isActive: map.boolean('isActive'),
      isVisible: map.boolean('isVisible'),
      isHiddenFromClient: map.boolean('isHiddenFromClient'),
      warehouseId: map.string('warehouseId'),
      locationId: map.string('locationId'),
      createdAt: map.string('createdAt'),
      updatedAt: map.string('updatedAt'),
    );
  }
}

final class StatusList {
  const StatusList({required this.data});

  final List<Status> data;

  factory StatusList.fromJson(Object? json) {
    return StatusList(data: JsonMap.of(json).list('data', Status.fromJson));
  }
}

/// Cuerpo de `statuses.update`.
///
/// `warehouseId` o `locationId` en `null` quita ese vínculo.
/// `category` `shipment` ya no se puede guardar.
class StatusWrite {
  const StatusWrite({
    this.label,
    this.description,
    this.position,
    this.category,
    this.icon,
    this.isActive,
    this.isVisible,
    this.isHiddenFromClient,
    Object? warehouseId = absent,
    Object? locationId = absent,
  })  : _warehouseId = warehouseId,
        _locationId = locationId;

  final String? label;
  final String? description;

  /// Orden en el panel. De 1 a 30.
  final int? position;
  final StatusCategory? category;
  final String? icon;
  final bool? isActive;
  final bool? isVisible;
  final bool? isHiddenFromClient;
  final Object? _warehouseId;
  final Object? _locationId;

  Map<String, Object?> toJson() => compact({
        if (label != null) 'label': label,
        if (description != null) 'description': description,
        if (position != null) 'position': position,
        if (category != null) 'category': category!.wire,
        if (icon != null) 'icon': icon,
        if (isActive != null) 'isActive': isActive,
        if (isVisible != null) 'isVisible': isVisible,
        if (isHiddenFromClient != null) 'isHiddenFromClient': isHiddenFromClient,
        'warehouseId': _warehouseId,
        'locationId': _locationId,
      });
}

/// Cuerpo de `statuses.create`.
///
/// Hacen falta `label`, `description`, `category` e `icon`.
/// `category` es `package`, `other` o `fleet`.
final class StatusCreate extends StatusWrite {
  const StatusCreate({
    required super.label,
    required super.description,
    required super.category,
    required super.icon,
    super.position,
    super.isActive,
    super.isVisible,
    super.isHiddenFromClient,
    super.warehouseId,
    super.locationId,
  });
}

/// Office de la organización.
///
/// `type` distingue la sucursal de atención de la bodega. El precio por libra
/// solo viene cuando `type` es `warehouse`.
final class Office {
  const Office({
    required this.id,
    required this.type,
    required this.name,
    required this.isActive,
    required this.isMain,
    required this.countryCode,
    required this.stateOrProvince,
    required this.stateCode,
    required this.city,
    required this.cityCode,
    required this.address,
    required this.suiteOrApt,
    required this.postalCode,
    required this.phoneNumber,
    required this.fax,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    this.pricePerPoundClient,
    this.pricePerPoundProvider,
  });

  final String id;
  final OfficeType type;
  final String? name;
  final bool isActive;
  final bool isMain;
  final String countryCode;
  final String stateOrProvince;
  final String stateCode;
  final String city;
  final String cityCode;
  final String address;
  final String suiteOrApt;
  final String postalCode;
  final String phoneNumber;
  final String fax;
  final String note;
  final String? createdAt;
  final String? updatedAt;
  final double? pricePerPoundClient;
  final double? pricePerPoundProvider;

  factory Office.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return Office(
      id: map.string('id') ?? '',
      type: OfficeType.tryParse(map.string('type')) ?? OfficeType.office,
      name: map.string('name'),
      isActive: map.boolean('isActive'),
      isMain: map.boolean('isMain'),
      countryCode: map.string('countryCode') ?? '',
      stateOrProvince: map.string('stateOrProvince') ?? '',
      stateCode: map.string('stateCode') ?? '',
      city: map.string('city') ?? '',
      cityCode: map.string('cityCode') ?? '',
      address: map.string('address') ?? '',
      suiteOrApt: map.string('suiteOrApt') ?? '',
      postalCode: map.string('postalCode') ?? '',
      phoneNumber: map.string('phoneNumber') ?? '',
      fax: map.string('fax') ?? '',
      note: map.string('note') ?? '',
      createdAt: map.string('createdAt'),
      updatedAt: map.string('updatedAt'),
      pricePerPoundClient: map.numberOrNull('pricePerPoundClient'),
      pricePerPoundProvider: map.numberOrNull('pricePerPoundProvider'),
    );
  }
}

final class OfficeList {
  const OfficeList({required this.data});

  final List<Office> data;

  factory OfficeList.fromJson(Object? json) {
    return OfficeList(data: JsonMap.of(json).list('data', Office.fromJson));
  }
}

/// Bodega: un office con `type: warehouse` y precio por libra.
final class Warehouse {
  const Warehouse({
    required this.id,
    required this.name,
    required this.isActive,
    required this.isMain,
    required this.countryCode,
    required this.stateOrProvince,
    required this.stateCode,
    required this.city,
    required this.cityCode,
    required this.address,
    required this.suiteOrApt,
    required this.postalCode,
    required this.phoneNumber,
    required this.fax,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.pricePerPoundClient,
    required this.pricePerPoundProvider,
  });

  final String id;
  final OfficeType type = OfficeType.warehouse;
  final String? name;
  final bool isActive;
  final bool isMain;
  final String countryCode;
  final String stateOrProvince;
  final String stateCode;
  final String city;
  final String cityCode;
  final String address;
  final String suiteOrApt;
  final String postalCode;
  final String phoneNumber;
  final String fax;
  final String note;
  final String? createdAt;
  final String? updatedAt;
  final double pricePerPoundClient;
  final double pricePerPoundProvider;

  factory Warehouse.fromJson(Object? json) {
    final office = Office.fromJson(json);
    return Warehouse(
      id: office.id,
      name: office.name,
      isActive: office.isActive,
      isMain: office.isMain,
      countryCode: office.countryCode,
      stateOrProvince: office.stateOrProvince,
      stateCode: office.stateCode,
      city: office.city,
      cityCode: office.cityCode,
      address: office.address,
      suiteOrApt: office.suiteOrApt,
      postalCode: office.postalCode,
      phoneNumber: office.phoneNumber,
      fax: office.fax,
      note: office.note,
      createdAt: office.createdAt,
      updatedAt: office.updatedAt,
      pricePerPoundClient: office.pricePerPoundClient ?? 0,
      pricePerPoundProvider: office.pricePerPoundProvider ?? 0,
    );
  }
}

final class WarehouseList {
  const WarehouseList({required this.data});

  final List<Warehouse> data;

  factory WarehouseList.fromJson(Object? json) {
    return WarehouseList(
      data: JsonMap.of(json).list('data', Warehouse.fromJson),
    );
  }
}

final class PackageParty {
  const PackageParty({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.companyName,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? companyName;

  factory PackageParty.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return PackageParty(
      id: map.string('id') ?? '',
      firstName: map.string('firstName'),
      lastName: map.string('lastName'),
      companyName: map.string('companyName'),
    );
  }
}

final class PackageStatus {
  const PackageStatus({required this.id, required this.name});

  final String id;
  final String name;

  factory PackageStatus.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return PackageStatus(
      id: map.string('id') ?? '',
      name: map.string('name') ?? '',
    );
  }
}

final class PackageOffice {
  const PackageOffice({required this.id, required this.name});

  final String id;
  final String name;

  factory PackageOffice.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return PackageOffice(
      id: map.string('id') ?? '',
      name: map.string('name') ?? '',
    );
  }
}

final class PackageFile {
  const PackageFile({
    required this.name,
    required this.url,
    required this.type,
  });

  final String name;
  final String url;
  final String type;

  Map<String, Object?> toJson() => {'name': name, 'url': url, 'type': type};

  factory PackageFile.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return PackageFile(
      name: map.string('name') ?? '',
      url: map.string('url') ?? '',
      type: map.string('type') ?? '',
    );
  }
}

/// Caja dentro de un paquete.
final class PackagePiece {
  const PackagePiece({
    this.quantity,
    this.weight,
    this.length,
    this.width,
    this.height,
    this.declaredValue,
    this.trackingNumber,
    this.comments,
    this.warehouseFileUrl,
  });

  final int? quantity;
  final double? weight;
  final double? length;
  final double? width;
  final double? height;
  final double? declaredValue;
  final String? trackingNumber;
  final String? comments;
  final List<PackageFile>? warehouseFileUrl;

  Map<String, Object?> toJson() => compact({
        if (quantity != null) 'quantity': quantity,
        if (weight != null) 'weight': weight,
        if (length != null) 'length': length,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (declaredValue != null) 'declaredValue': declaredValue,
        if (trackingNumber != null) 'trackingNumber': trackingNumber,
        if (comments != null) 'comments': comments,
        if (warehouseFileUrl != null)
          'warehouseFileUrl': [
            for (final file in warehouseFileUrl!) file.toJson(),
          ],
      });
}

/// Paquete exportado por la Org API.
final class Package {
  const Package({
    required this.id,
    required this.packageType,
    required this.serialNumber,
    required this.receiptPackageIndex,
    required this.receiptNumber,
    required this.packageNumber,
    required this.trackingNumber,
    required this.trackingNormalized,
    required this.weight,
    required this.weightUnit,
    required this.volumetricWeight,
    required this.chargeableWeight,
    required this.declaredValue,
    required this.height,
    required this.width,
    required this.length,
    required this.dimensionUnit,
    required this.pieces,
    required this.comments,
    required this.warehouseComments,
    required this.isConsolidated,
    required this.isGrouped,
    required this.guideId,
    required this.saleId,
    required this.rackCode,
    required this.registrationDate,
    required this.createdAt,
    required this.updatedAt,
    required this.itemStatus,
    required this.customer,
    required this.shipper,
    required this.location,
    required this.warehouse,
  });

  final String id;
  final PackageType packageType;
  final int? serialNumber;
  final int receiptPackageIndex;
  final String? receiptNumber;
  final String? packageNumber;
  final String? trackingNumber;
  final String? trackingNormalized;
  final double weight;
  final String? weightUnit;
  final double volumetricWeight;
  final double chargeableWeight;
  final double declaredValue;
  final double height;
  final double width;
  final double length;
  final String? dimensionUnit;
  final int pieces;
  final String? comments;
  final String? warehouseComments;
  final bool isConsolidated;
  final bool isGrouped;
  final String? guideId;
  final String? saleId;
  final String? rackCode;
  final String registrationDate;
  final String createdAt;
  final String updatedAt;
  final PackageStatus? itemStatus;
  final PackageParty? customer;
  final PackageParty? shipper;
  final PackageOffice? location;
  final PackageOffice? warehouse;

  factory Package.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return Package(
      id: map.string('id') ?? '',
      packageType:
          PackageType.tryParse(map.string('packageType')) ?? PackageType.wr,
      serialNumber: map.integerOrNull('serialNumber'),
      receiptPackageIndex: map.integer('receiptPackageIndex'),
      receiptNumber: map.string('receiptNumber'),
      packageNumber: map.string('packageNumber'),
      trackingNumber: map.string('trackingNumber'),
      trackingNormalized: map.string('trackingNormalized'),
      weight: map.number('weight'),
      weightUnit: map.string('weightUnit'),
      volumetricWeight: map.number('volumetricWeight'),
      chargeableWeight: map.number('chargeableWeight'),
      declaredValue: map.number('declaredValue'),
      height: map.number('height'),
      width: map.number('width'),
      length: map.number('length'),
      dimensionUnit: map.string('dimensionUnit'),
      pieces: map.integer('pieces'),
      comments: map.string('comments'),
      warehouseComments: map.string('warehouseComments'),
      isConsolidated: map.boolean('isConsolidated'),
      isGrouped: map.boolean('isGrouped'),
      guideId: map.string('guideId'),
      saleId: map.string('saleId'),
      rackCode: map.string('rackCode'),
      registrationDate: map.string('registrationDate') ?? '',
      createdAt: map.string('createdAt') ?? '',
      updatedAt: map.string('updatedAt') ?? '',
      itemStatus: map.object('itemStatus', PackageStatus.fromJson),
      customer: map.object('customer', PackageParty.fromJson),
      shipper: map.object('shipper', PackageParty.fromJson),
      location: map.object('location', PackageOffice.fromJson),
      warehouse: map.object('warehouse', PackageOffice.fromJson),
    );
  }
}

final class PackageExport {
  const PackageExport({
    required this.data,
    required this.total,
    required this.exportedAt,
  });

  final List<Package> data;
  final int total;
  final String exportedAt;

  factory PackageExport.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return PackageExport(
      data: map.list('data', Package.fromJson),
      total: map.integer('total'),
      exportedAt: map.string('exportedAt') ?? '',
    );
  }
}

final class MisiilPackageExport extends PackageExport {
  const MisiilPackageExport({
    required super.data,
    required super.total,
    required super.exportedAt,
    required this.source,
  });

  final String source;

  factory MisiilPackageExport.fromJson(Object? json) {
    final base = PackageExport.fromJson(json);
    return MisiilPackageExport(
      data: base.data,
      total: base.total,
      exportedAt: base.exportedAt,
      source: JsonMap.of(json).string('source') ?? 'misiil',
    );
  }
}

/// Campos de `packages.create` y `packages.update`.
///
/// En el alta hacen falta `registrationDate`, `trackingNumber`, `itemStatusId`
/// y `locationId`.
class PackageWrite {
  const PackageWrite({
    this.registrationDate,
    this.trackingNumber,
    this.externalReceiptCode,
    this.receiptPackageIndex,
    this.receiptSerialNumber,
    this.declaredValue,
    this.weight,
    this.height,
    this.width,
    this.length,
    this.pieces,
    this.packagePieces,
    this.volumetricWeight,
    this.chargeableWeight,
    this.volumetricRule,
    this.volumetricDivisor,
    this.weightUnit,
    this.dimensionUnit,
    this.itemStatusId,
    this.customerId,
    this.shipperId,
    this.warehouseId,
    this.locationId,
    this.customerShippingAddressId,
    this.shipperShippingAddressId,
    this.comments,
    this.warehouseComments,
    this.isConsolidated,
    this.isGrouped,
    this.warehouseFileUrl,
    this.propagatePartiesToReceiptSiblings,
  });

  final String? registrationDate;
  final String? trackingNumber;

  /// Recibo de proveedor (`WHR…`). El paquete no consume la secuencia WR.
  final String? externalReceiptCode;

  /// 1 → P1. Por defecto 1.
  final int? receiptPackageIndex;

  /// Serial de un recibo ya creado, para agregar P2, P3…
  final int? receiptSerialNumber;
  final double? declaredValue;
  final double? weight;
  final double? height;
  final double? width;
  final double? length;
  final int? pieces;
  final List<PackagePiece>? packagePieces;
  final double? volumetricWeight;
  final double? chargeableWeight;
  final String? volumetricRule;
  final double? volumetricDivisor;
  final String? weightUnit;
  final String? dimensionUnit;
  final String? itemStatusId;
  final String? customerId;
  final String? shipperId;
  final String? warehouseId;
  final String? locationId;
  final String? customerShippingAddressId;
  final String? shipperShippingAddressId;

  /// Descripción de la mercancía.
  final String? comments;

  /// Nota de bodega.
  final String? warehouseComments;
  final bool? isConsolidated;
  final bool? isGrouped;
  final List<PackageFile>? warehouseFileUrl;

  /// En un update, copia remitente y destinatario al resto del recibo.
  final bool? propagatePartiesToReceiptSiblings;

  Map<String, Object?> toJson() => compact({
        if (registrationDate != null) 'registrationDate': registrationDate,
        if (trackingNumber != null) 'trackingNumber': trackingNumber,
        if (externalReceiptCode != null)
          'externalReceiptCode': externalReceiptCode,
        if (receiptPackageIndex != null)
          'receiptPackageIndex': receiptPackageIndex,
        if (receiptSerialNumber != null)
          'receiptSerialNumber': receiptSerialNumber,
        if (declaredValue != null) 'declaredValue': declaredValue,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
        if (width != null) 'width': width,
        if (length != null) 'length': length,
        if (pieces != null) 'pieces': pieces,
        if (packagePieces != null)
          'packagePieces': [for (final piece in packagePieces!) piece.toJson()],
        if (volumetricWeight != null) 'volumetricWeight': volumetricWeight,
        if (chargeableWeight != null) 'chargeableWeight': chargeableWeight,
        if (volumetricRule != null) 'volumetricRule': volumetricRule,
        if (volumetricDivisor != null) 'volumetricDivisor': volumetricDivisor,
        if (weightUnit != null) 'weightUnit': weightUnit,
        if (dimensionUnit != null) 'dimensionUnit': dimensionUnit,
        if (itemStatusId != null) 'itemStatusId': itemStatusId,
        if (customerId != null) 'customerId': customerId,
        if (shipperId != null) 'shipperId': shipperId,
        if (warehouseId != null) 'warehouseId': warehouseId,
        if (locationId != null) 'locationId': locationId,
        if (customerShippingAddressId != null)
          'customerShippingAddressId': customerShippingAddressId,
        if (shipperShippingAddressId != null)
          'shipperShippingAddressId': shipperShippingAddressId,
        if (comments != null) 'comments': comments,
        if (warehouseComments != null) 'warehouseComments': warehouseComments,
        if (isConsolidated != null) 'isConsolidated': isConsolidated,
        if (isGrouped != null) 'isGrouped': isGrouped,
        if (warehouseFileUrl != null)
          'warehouseFileUrl': [
            for (final file in warehouseFileUrl!) file.toJson()
          ],
        if (propagatePartiesToReceiptSiblings != null)
          'propagatePartiesToReceiptSiblings':
              propagatePartiesToReceiptSiblings,
      });
}

/// Cuerpo de `packages.create`.
final class PackageCreate extends PackageWrite {
  // Los cuatro campos del alta son `String`, no el `String?` del padre.
  // ignore: use_super_parameters
  const PackageCreate({
    required String registrationDate,
    required String trackingNumber,
    required String itemStatusId,
    required String locationId,
    String? externalReceiptCode,
    int? receiptPackageIndex,
    int? receiptSerialNumber,
    double? declaredValue,
    double? weight,
    double? height,
    double? width,
    double? length,
    int? pieces,
    List<PackagePiece>? packagePieces,
    double? volumetricWeight,
    double? chargeableWeight,
    String? volumetricRule,
    double? volumetricDivisor,
    String? weightUnit,
    String? dimensionUnit,
    String? customerId,
    String? shipperId,
    String? warehouseId,
    String? customerShippingAddressId,
    String? shipperShippingAddressId,
    String? comments,
    String? warehouseComments,
    bool? isConsolidated,
    bool? isGrouped,
    List<PackageFile>? warehouseFileUrl,
    bool? propagatePartiesToReceiptSiblings,
  }) : super(
          registrationDate: registrationDate,
          trackingNumber: trackingNumber,
          itemStatusId: itemStatusId,
          locationId: locationId,
          externalReceiptCode: externalReceiptCode,
          receiptPackageIndex: receiptPackageIndex,
          receiptSerialNumber: receiptSerialNumber,
          declaredValue: declaredValue,
          weight: weight,
          height: height,
          width: width,
          length: length,
          pieces: pieces,
          packagePieces: packagePieces,
          volumetricWeight: volumetricWeight,
          chargeableWeight: chargeableWeight,
          volumetricRule: volumetricRule,
          volumetricDivisor: volumetricDivisor,
          weightUnit: weightUnit,
          dimensionUnit: dimensionUnit,
          customerId: customerId,
          shipperId: shipperId,
          warehouseId: warehouseId,
          customerShippingAddressId: customerShippingAddressId,
          shipperShippingAddressId: shipperShippingAddressId,
          comments: comments,
          warehouseComments: warehouseComments,
          isConsolidated: isConsolidated,
          isGrouped: isGrouped,
          warehouseFileUrl: warehouseFileUrl,
          propagatePartiesToReceiptSiblings: propagatePartiesToReceiptSiblings,
        );
}

/// Una pieza al crear un recibo. El orden de la lista es P1, P2… si no se envía índice.
final class ReceiptPackageLine {
  const ReceiptPackageLine({
    required this.trackingNumber,
    this.receiptPackageIndex,
    this.declaredValue,
    this.weight,
    this.height,
    this.width,
    this.length,
    this.pieces,
    this.comments,
    this.warehouseComments,
    this.customerId,
    this.shipperId,
    this.customerShippingAddressId,
    this.shipperShippingAddressId,
    this.packagePieces,
    this.warehouseFileUrl,
  });

  final String trackingNumber;
  final int? receiptPackageIndex;
  final double? declaredValue;
  final double? weight;
  final double? height;
  final double? width;
  final double? length;
  final int? pieces;
  final String? comments;
  final String? warehouseComments;
  final String? customerId;
  final String? shipperId;
  final String? customerShippingAddressId;
  final String? shipperShippingAddressId;
  final List<PackagePiece>? packagePieces;
  final List<PackageFile>? warehouseFileUrl;

  Map<String, Object?> toJson() => compact({
        'trackingNumber': trackingNumber,
        if (receiptPackageIndex != null)
          'receiptPackageIndex': receiptPackageIndex,
        if (declaredValue != null) 'declaredValue': declaredValue,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
        if (width != null) 'width': width,
        if (length != null) 'length': length,
        if (pieces != null) 'pieces': pieces,
        if (comments != null) 'comments': comments,
        if (warehouseComments != null) 'warehouseComments': warehouseComments,
        if (customerId != null) 'customerId': customerId,
        if (shipperId != null) 'shipperId': shipperId,
        if (customerShippingAddressId != null)
          'customerShippingAddressId': customerShippingAddressId,
        if (shipperShippingAddressId != null)
          'shipperShippingAddressId': shipperShippingAddressId,
        if (packagePieces != null)
          'packagePieces': [for (final piece in packagePieces!) piece.toJson()],
        if (warehouseFileUrl != null)
          'warehouseFileUrl': [
            for (final file in warehouseFileUrl!) file.toJson()
          ],
      });
}

/// Pieza ya guardada dentro de `receipts.update`.
final class ReceiptPackagePatch {
  const ReceiptPackagePatch({
    required this.id,
    this.trackingNumber,
    this.receiptPackageIndex,
    this.declaredValue,
    this.weight,
    this.height,
    this.width,
    this.length,
    this.pieces,
    this.comments,
    this.warehouseComments,
    this.customerId,
    this.shipperId,
    this.customerShippingAddressId,
    this.shipperShippingAddressId,
    this.packagePieces,
    this.warehouseFileUrl,
  });

  final String id;
  final String? trackingNumber;
  final int? receiptPackageIndex;
  final double? declaredValue;
  final double? weight;
  final double? height;
  final double? width;
  final double? length;
  final int? pieces;
  final String? comments;
  final String? warehouseComments;
  final String? customerId;
  final String? shipperId;
  final String? customerShippingAddressId;
  final String? shipperShippingAddressId;
  final List<PackagePiece>? packagePieces;
  final List<PackageFile>? warehouseFileUrl;

  Map<String, Object?> toJson() => compact({
        'id': id,
        if (trackingNumber != null) 'trackingNumber': trackingNumber,
        if (receiptPackageIndex != null)
          'receiptPackageIndex': receiptPackageIndex,
        if (declaredValue != null) 'declaredValue': declaredValue,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
        if (width != null) 'width': width,
        if (length != null) 'length': length,
        if (pieces != null) 'pieces': pieces,
        if (comments != null) 'comments': comments,
        if (warehouseComments != null) 'warehouseComments': warehouseComments,
        if (customerId != null) 'customerId': customerId,
        if (shipperId != null) 'shipperId': shipperId,
        if (customerShippingAddressId != null)
          'customerShippingAddressId': customerShippingAddressId,
        if (shipperShippingAddressId != null)
          'shipperShippingAddressId': shipperShippingAddressId,
        if (packagePieces != null)
          'packagePieces': [for (final piece in packagePieces!) piece.toJson()],
        if (warehouseFileUrl != null)
          'warehouseFileUrl': [
            for (final file in warehouseFileUrl!) file.toJson()
          ],
      });
}

/// Cuerpo de `receipts.create`.
///
/// Las piezas comparten código de recibo. Sin `externalReceiptCode` el API reserva un WR.
final class ReceiptCreate {
  const ReceiptCreate({
    required this.registrationDate,
    required this.locationId,
    required this.itemStatusId,
    required this.packages,
    this.externalReceiptCode,
    this.customerId,
    this.shipperId,
    this.warehouseId,
    this.customerShippingAddressId,
    this.shipperShippingAddressId,
    this.weightUnit,
    this.dimensionUnit,
    this.volumetricRule,
    this.volumetricDivisor,
    this.comments,
    this.warehouseComments,
  });

  final String registrationDate;
  final String locationId;
  final String itemStatusId;
  final String? externalReceiptCode;
  final String? customerId;
  final String? shipperId;
  final String? warehouseId;
  final String? customerShippingAddressId;
  final String? shipperShippingAddressId;
  final String? weightUnit;
  final String? dimensionUnit;
  final String? volumetricRule;
  final double? volumetricDivisor;
  final String? comments;
  final String? warehouseComments;
  final List<ReceiptPackageLine> packages;

  Map<String, Object?> toJson() => compact({
        'registrationDate': registrationDate,
        'locationId': locationId,
        'itemStatusId': itemStatusId,
        if (externalReceiptCode != null)
          'externalReceiptCode': externalReceiptCode,
        if (customerId != null) 'customerId': customerId,
        if (shipperId != null) 'shipperId': shipperId,
        if (warehouseId != null) 'warehouseId': warehouseId,
        if (customerShippingAddressId != null)
          'customerShippingAddressId': customerShippingAddressId,
        if (shipperShippingAddressId != null)
          'shipperShippingAddressId': shipperShippingAddressId,
        if (weightUnit != null) 'weightUnit': weightUnit,
        if (dimensionUnit != null) 'dimensionUnit': dimensionUnit,
        if (volumetricRule != null) 'volumetricRule': volumetricRule,
        if (volumetricDivisor != null) 'volumetricDivisor': volumetricDivisor,
        if (comments != null) 'comments': comments,
        if (warehouseComments != null) 'warehouseComments': warehouseComments,
        'packages': [for (final line in packages) line.toJson()],
      });
}

/// Cuerpo de `receipts.update`.
///
/// Los campos de arriba se aplican a todas las piezas. `packages` cambia una pieza por id.
final class ReceiptUpdate {
  const ReceiptUpdate({
    this.registrationDate,
    this.locationId,
    this.itemStatusId,
    this.customerId,
    this.shipperId,
    this.warehouseId,
    this.customerShippingAddressId,
    this.shipperShippingAddressId,
    this.weightUnit,
    this.dimensionUnit,
    this.volumetricRule,
    this.volumetricDivisor,
    this.comments,
    this.warehouseComments,
    this.packages,
  });

  final String? registrationDate;
  final String? locationId;
  final String? itemStatusId;
  final String? customerId;
  final String? shipperId;
  final String? warehouseId;
  final String? customerShippingAddressId;
  final String? shipperShippingAddressId;
  final String? weightUnit;
  final String? dimensionUnit;
  final String? volumetricRule;
  final double? volumetricDivisor;
  final String? comments;
  final String? warehouseComments;
  final List<ReceiptPackagePatch>? packages;

  Map<String, Object?> toJson() => compact({
        if (registrationDate != null) 'registrationDate': registrationDate,
        if (locationId != null) 'locationId': locationId,
        if (itemStatusId != null) 'itemStatusId': itemStatusId,
        if (customerId != null) 'customerId': customerId,
        if (shipperId != null) 'shipperId': shipperId,
        if (warehouseId != null) 'warehouseId': warehouseId,
        if (customerShippingAddressId != null)
          'customerShippingAddressId': customerShippingAddressId,
        if (shipperShippingAddressId != null)
          'shipperShippingAddressId': shipperShippingAddressId,
        if (weightUnit != null) 'weightUnit': weightUnit,
        if (dimensionUnit != null) 'dimensionUnit': dimensionUnit,
        if (volumetricRule != null) 'volumetricRule': volumetricRule,
        if (volumetricDivisor != null) 'volumetricDivisor': volumetricDivisor,
        if (comments != null) 'comments': comments,
        if (warehouseComments != null) 'warehouseComments': warehouseComments,
        if (packages != null)
          'packages': [for (final line in packages!) line.toJson()],
      });
}

/// Recibo: grupo de paquetes con el mismo código.
///
/// `id` es el id del primer paquete (P1). Sirve para retrieve, update y delete
/// aunque pases el id de otra pieza del mismo recibo.
final class Receipt {
  const Receipt({
    required this.id,
    required this.receiptNumber,
    required this.serialNumber,
    required this.locationId,
    required this.packageCount,
    required this.registrationDate,
    required this.totalWeight,
    required this.totalPieces,
    required this.totalDeclaredValue,
    required this.guideId,
    required this.isLocked,
    required this.trackingNumbers,
    required this.customer,
    required this.shipper,
    required this.itemStatus,
    required this.location,
    this.packages,
  });

  final String id;
  final String? receiptNumber;
  final int? serialNumber;
  final String? locationId;
  final int packageCount;
  final String? registrationDate;
  final double totalWeight;
  final int totalPieces;
  final double totalDeclaredValue;
  final String? guideId;
  final bool isLocked;
  final String? trackingNumbers;
  final PackageParty? customer;
  final PackageParty? shipper;
  final PackageStatus? itemStatus;
  final PackageOffice? location;

  /// Presente en retrieve, create y update. El listado no lo trae.
  final List<Package>? packages;

  factory Receipt.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return Receipt(
      id: map.string('id') ?? '',
      receiptNumber: map.string('receiptNumber'),
      serialNumber: map.integerOrNull('serialNumber'),
      locationId: map.string('locationId'),
      packageCount: map.integer('packageCount'),
      registrationDate: map.string('registrationDate'),
      totalWeight: map.number('totalWeight'),
      totalPieces: map.integer('totalPieces'),
      totalDeclaredValue: map.number('totalDeclaredValue'),
      guideId: map.string('guideId'),
      isLocked: map.boolean('isLocked'),
      trackingNumbers: map.string('trackingNumbers'),
      customer: map.object('customer', PackageParty.fromJson),
      shipper: map.object('shipper', PackageParty.fromJson),
      itemStatus: map.object('itemStatus', PackageStatus.fromJson),
      location: map.object('location', PackageOffice.fromJson),
      packages: map.listOrNull('packages', Package.fromJson),
    );
  }
}

final class DirectoryPagination {
  const DirectoryPagination({
    required this.limit,
    this.total,
    this.page,
    this.totalPages,
    this.hasNextPage,
    this.hasPrevPage,
    this.nextCursor,
  });

  final int? total;
  final int? page;
  final int limit;
  final int? totalPages;
  final bool? hasNextPage;
  final bool? hasPrevPage;
  final String? nextCursor;

  factory DirectoryPagination.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return DirectoryPagination(
      total: map.integerOrNull('total'),
      page: map.integerOrNull('page'),
      limit: map.integer('limit'),
      totalPages: map.integerOrNull('totalPages'),
      hasNextPage: map.booleanOrNull('hasNextPage'),
      hasPrevPage: map.booleanOrNull('hasPrevPage'),
      nextCursor: map.string('nextCursor'),
    );
  }
}

final class ReceiptPage {
  const ReceiptPage({required this.data, required this.pagination});

  final List<Receipt> data;
  final DirectoryPagination pagination;

  factory ReceiptPage.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return ReceiptPage(
      data: map.list('data', Receipt.fromJson),
      pagination: DirectoryPagination.fromJson(map.map['pagination']),
    );
  }
}

final class DeletedResource {
  const DeletedResource({required this.id, required this.deleted});

  final String id;
  final bool deleted;

  factory DeletedResource.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return DeletedResource(
      id: map.string('id') ?? '',
      deleted: map.boolean('deleted'),
    );
  }
}

final class DeletedReceipt extends DeletedResource {
  const DeletedReceipt({
    required super.id,
    required super.deleted,
    required this.deletedCount,
  });

  final int deletedCount;

  factory DeletedReceipt.fromJson(Object? json) {
    final base = DeletedResource.fromJson(json);
    return DeletedReceipt(
      id: base.id,
      deleted: base.deleted,
      deletedCount: JsonMap.of(json).integer('deletedCount'),
    );
  }
}

final class DirectoryEmail {
  const DirectoryEmail({required this.value, this.label});

  final String? label;
  final String value;

  Map<String, Object?> toJson() => compact({
        if (label != null) 'label': label,
        'value': value,
      });

  factory DirectoryEmail.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return DirectoryEmail(
      label: map.string('label'),
      value: map.string('value') ?? '',
    );
  }
}

final class DirectoryPhone {
  const DirectoryPhone({required this.value, this.label, this.channel});

  final String? label;
  final String value;
  final PhoneChannel? channel;

  Map<String, Object?> toJson() => compact({
        if (label != null) 'label': label,
        'value': value,
        if (channel != null) 'channel': channel!.wire,
      });

  factory DirectoryPhone.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return DirectoryPhone(
      label: map.string('label'),
      value: map.string('value') ?? '',
      channel: PhoneChannel.tryParse(map.string('channel')),
    );
  }
}

final class DirectoryTag {
  const DirectoryTag({required this.id, required this.name, this.color});

  final String id;
  final String name;
  final String? color;

  factory DirectoryTag.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return DirectoryTag(
      id: map.string('id') ?? '',
      name: map.string('name') ?? '',
      color: map.string('color'),
    );
  }
}

final class DirectoryPage<T> {
  const DirectoryPage({required this.data, required this.pagination});

  final List<T> data;
  final DirectoryPagination pagination;

  static DirectoryPage<T> Function(Object? json) decoder<T>(
    T Function(Object? json) decodeItem,
  ) {
    return (Object? json) {
      final map = JsonMap.of(json);
      return DirectoryPage(
        data: map.list('data', decodeItem),
        pagination: DirectoryPagination.fromJson(map.map['pagination']),
      );
    };
  }
}

/// Cliente de la organización.
final class Customer {
  const Customer({
    required this.id,
    required this.accountType,
    required this.companyName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.nationality,
    required this.identityType,
    required this.identityNumber,
    required this.whatsapp,
    required this.emails,
    required this.phones,
    required this.city,
    required this.stateOrProvince,
    required this.address,
    required this.postalCode,
    required this.note,
    required this.mailbox,
    required this.enterpriseCode,
    required this.isActive,
    required this.types,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final AccountType? accountType;
  final String? companyName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? username;
  final String? nationality;
  final String? identityType;
  final String? identityNumber;
  final String? whatsapp;
  final List<DirectoryEmail> emails;
  final List<DirectoryPhone> phones;
  final String? city;
  final String? stateOrProvince;
  final String? address;
  final String? postalCode;
  final String? note;
  final String? mailbox;
  final String? enterpriseCode;
  final bool isActive;

  /// Siempre `CLIENT`. Los roles operativos se envían en el contacto.
  final List<CustomerType> types;
  final List<DirectoryTag> tags;
  final String? createdAt;
  final String? updatedAt;

  factory Customer.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return Customer(
      id: map.string('id') ?? '',
      accountType: AccountType.tryParse(map.string('accountType')),
      companyName: map.string('companyName'),
      firstName: map.string('firstName'),
      lastName: map.string('lastName'),
      email: map.string('email'),
      username: map.string('username'),
      nationality: map.string('nationality'),
      identityType: map.string('identityType'),
      identityNumber: map.string('identityNumber'),
      whatsapp: map.string('whatsapp'),
      emails: map.list('emails', DirectoryEmail.fromJson),
      phones: map.list('phones', DirectoryPhone.fromJson),
      city: map.string('city'),
      stateOrProvince: map.string('stateOrProvince'),
      address: map.string('address'),
      postalCode: map.string('postalCode'),
      note: map.string('note'),
      mailbox: map.string('mailbox'),
      enterpriseCode: map.string('enterpriseCode'),
      isActive: map.boolean('isActive'),
      types: [
        for (final item in map.list('types', (value) => value))
          if (item is String) CustomerType.parse(item),
      ],
      tags: map.list('tags', DirectoryTag.fromJson),
      createdAt: map.string('createdAt'),
      updatedAt: map.string('updatedAt'),
    );
  }
}

/// Cuerpo de `customers.create` y `customers.update`.
///
/// No incluye `types`: el API guarda siempre `CLIENT`.
class CustomerWrite {
  const CustomerWrite({
    this.accountType,
    this.companyName,
    this.nationality,
    this.identityType,
    this.identityNumber,
    this.email,
    this.username,
    this.whatsapp,
    this.lastName,
    this.firstName,
    this.city,
    this.stateOrProvince,
    this.address,
    this.postalCode,
    this.note,
    this.mailbox,
    this.isActive,
    this.emails,
    this.phones,
    this.tagIds,
  });

  final AccountType? accountType;
  final String? companyName;
  final String? nationality;
  final String? identityType;
  final String? identityNumber;
  final String? email;
  final String? username;
  final String? whatsapp;
  final String? lastName;
  final String? firstName;
  final String? city;
  final String? stateOrProvince;
  final String? address;
  final String? postalCode;
  final String? note;
  final String? mailbox;
  final bool? isActive;
  final List<DirectoryEmail>? emails;
  final List<DirectoryPhone>? phones;
  final List<String>? tagIds;

  Map<String, Object?> toJson() => compact({
        if (accountType != null) 'accountType': accountType!.wire,
        if (companyName != null) 'companyName': companyName,
        if (nationality != null) 'nationality': nationality,
        if (identityType != null) 'identityType': identityType,
        if (identityNumber != null) 'identityNumber': identityNumber,
        if (email != null) 'email': email,
        if (username != null) 'username': username,
        if (whatsapp != null) 'whatsapp': whatsapp,
        if (lastName != null) 'lastName': lastName,
        if (firstName != null) 'firstName': firstName,
        if (city != null) 'city': city,
        if (stateOrProvince != null) 'stateOrProvince': stateOrProvince,
        if (address != null) 'address': address,
        if (postalCode != null) 'postalCode': postalCode,
        if (note != null) 'note': note,
        if (mailbox != null) 'mailbox': mailbox,
        if (isActive != null) 'isActive': isActive,
        if (emails != null)
          'emails': [for (final email in emails!) email.toJson()],
        if (phones != null)
          'phones': [for (final phone in phones!) phone.toJson()],
        if (tagIds != null) 'tagIds': tagIds,
      });
}

/// Cuerpo de `customers.create`.
///
/// `createContact` decide si el API también crea el contacto SHIPPER.
final class CustomerCreate extends CustomerWrite {
  const CustomerCreate({
    super.accountType,
    super.companyName,
    super.nationality,
    super.identityType,
    super.identityNumber,
    super.email,
    super.username,
    super.whatsapp,
    super.lastName,
    super.firstName,
    super.city,
    super.stateOrProvince,
    super.address,
    super.postalCode,
    super.note,
    super.mailbox,
    super.isActive,
    super.emails,
    super.phones,
    super.tagIds,
    this.createContact,
  });

  /// `true` o ausente: crea un contacto `SHIPPER` con los mismos datos del cliente.
  /// `false`: crea solo el cliente.
  final bool? createContact;

  @override
  Map<String, Object?> toJson() => compact({
        ...super.toJson(),
        if (createContact != null) 'createContact': createContact,
      });
}

final class ContactClient {
  const ContactClient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.email,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? companyName;
  final String? email;

  factory ContactClient.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return ContactClient(
      id: map.string('id') ?? '',
      firstName: map.string('firstName'),
      lastName: map.string('lastName'),
      companyName: map.string('companyName'),
      email: map.string('email'),
    );
  }
}

/// Contacto comercial, sin portal.
final class Contact {
  const Contact({
    required this.id,
    required this.accountType,
    required this.companyName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.nationality,
    required this.identityType,
    required this.identityNumber,
    required this.whatsapp,
    required this.emails,
    required this.phones,
    required this.city,
    required this.stateOrProvince,
    required this.address,
    required this.postalCode,
    required this.note,
    required this.isActive,
    required this.types,
    required this.clientId,
    required this.client,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final AccountType? accountType;
  final String? companyName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? nationality;
  final String? identityType;
  final String? identityNumber;
  final String? whatsapp;
  final List<DirectoryEmail> emails;
  final List<DirectoryPhone> phones;
  final String? city;
  final String? stateOrProvince;
  final String? address;
  final String? postalCode;
  final String? note;
  final bool isActive;

  /// Roles del contacto. Valores de [contactTypes]. Nunca `CLIENT`.
  final List<ContactType> types;
  final String? clientId;
  final ContactClient? client;
  final List<DirectoryTag> tags;
  final String? createdAt;
  final String? updatedAt;

  factory Contact.fromJson(Object? json) {
    final map = JsonMap.of(json);
    return Contact(
      id: map.string('id') ?? '',
      accountType: AccountType.tryParse(map.string('accountType')),
      companyName: map.string('companyName'),
      firstName: map.string('firstName'),
      lastName: map.string('lastName'),
      email: map.string('email'),
      nationality: map.string('nationality'),
      identityType: map.string('identityType'),
      identityNumber: map.string('identityNumber'),
      whatsapp: map.string('whatsapp'),
      emails: map.list('emails', DirectoryEmail.fromJson),
      phones: map.list('phones', DirectoryPhone.fromJson),
      city: map.string('city'),
      stateOrProvince: map.string('stateOrProvince'),
      address: map.string('address'),
      postalCode: map.string('postalCode'),
      note: map.string('note'),
      isActive: map.boolean('isActive'),
      types: [
        for (final item in map.list('types', (value) => value))
          if (item is String) ContactType.parse(item),
      ],
      clientId: map.string('clientId'),
      client: map.object('client', ContactClient.fromJson),
      tags: map.list('tags', DirectoryTag.fromJson),
      createdAt: map.string('createdAt'),
      updatedAt: map.string('updatedAt'),
    );
  }
}

/// Cuerpo de `contacts.create` y `contacts.update`.
final class ContactWrite {
  /// [clientId] vincula el contacto a un cliente.
  ///
  /// Pasa `null` para desvincularlo. Si omites el argumento, el vínculo no cambia.
  const ContactWrite({
    this.accountType,
    this.companyName,
    this.nationality,
    this.identityType,
    this.identityNumber,
    this.email,
    this.whatsapp,
    this.lastName,
    this.firstName,
    this.city,
    this.stateOrProvince,
    this.address,
    this.postalCode,
    this.note,
    this.isActive,
    this.emails,
    this.phones,
    this.types,
    Object? clientId = absent,
    this.tagIds,
  }) : _clientId = clientId;

  final AccountType? accountType;
  final String? companyName;
  final String? nationality;
  final String? identityType;
  final String? identityNumber;
  final String? email;
  final String? whatsapp;
  final String? lastName;
  final String? firstName;
  final String? city;
  final String? stateOrProvince;
  final String? address;
  final String? postalCode;
  final String? note;
  final bool? isActive;
  final List<DirectoryEmail>? emails;
  final List<DirectoryPhone>? phones;

  /// Roles a guardar. Si no se envía, el API deja `SHIPPER`.
  final List<ContactType>? types;
  final Object? _clientId;
  final List<String>? tagIds;

  Map<String, Object?> toJson() => compact({
        if (accountType != null) 'accountType': accountType!.wire,
        if (companyName != null) 'companyName': companyName,
        if (nationality != null) 'nationality': nationality,
        if (identityType != null) 'identityType': identityType,
        if (identityNumber != null) 'identityNumber': identityNumber,
        if (email != null) 'email': email,
        if (whatsapp != null) 'whatsapp': whatsapp,
        if (lastName != null) 'lastName': lastName,
        if (firstName != null) 'firstName': firstName,
        if (city != null) 'city': city,
        if (stateOrProvince != null) 'stateOrProvince': stateOrProvince,
        if (address != null) 'address': address,
        if (postalCode != null) 'postalCode': postalCode,
        if (note != null) 'note': note,
        if (isActive != null) 'isActive': isActive,
        if (emails != null)
          'emails': [for (final email in emails!) email.toJson()],
        if (phones != null)
          'phones': [for (final phone in phones!) phone.toJson()],
        if (types != null) 'types': [for (final type in types!) type.wire],
        'clientId': _clientId,
        if (tagIds != null) 'tagIds': tagIds,
      });
}
