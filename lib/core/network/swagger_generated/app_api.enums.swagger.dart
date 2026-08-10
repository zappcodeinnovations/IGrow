// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

enum AdminNotificationNotificationTypeEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('NEW_INSTRUCTOR')
  newInstructor('NEW_INSTRUCTOR'),
  @JsonValue('KYC_SUBMITTED')
  kycSubmitted('KYC_SUBMITTED'),
  @JsonValue('KYC_UPDATED')
  kycUpdated('KYC_UPDATED'),
  @JsonValue('INSTRUCTOR_SUSPENDED')
  instructorSuspended('INSTRUCTOR_SUSPENDED');

  final String? value;

  const AdminNotificationNotificationTypeEnum(this.value);
}

enum BlankEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('')
  $null('');

  final String? value;

  const BlankEnum(this.value);
}

enum BunnyStatusEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4);

  final int? value;

  const BunnyStatusEnum(this.value);
}

enum ContentTypeEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('COURSE')
  course('COURSE'),
  @JsonValue('EBOOK')
  ebook('EBOOK'),
  @JsonValue('BOTH')
  both('BOTH');

  final String? value;

  const ContentTypeEnum(this.value);
}

enum DeviceTypeEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('android')
  android('android'),
  @JsonValue('ios')
  ios('ios'),
  @JsonValue('web')
  web('web');

  final String? value;

  const DeviceTypeEnum(this.value);
}

enum FailedStepEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('TEXT_SCAN')
  textScan('TEXT_SCAN'),
  @JsonValue('AUDIO_WHISPER')
  audioWhisper('AUDIO_WHISPER'),
  @JsonValue('VISION_FRAME')
  visionFrame('VISION_FRAME');

  final String? value;

  const FailedStepEnum(this.value);
}

enum FarmingExperienceEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('BEGINNER')
  beginner('BEGINNER'),
  @JsonValue('INTERMEDIATE')
  intermediate('INTERMEDIATE'),
  @JsonValue('EXPERT')
  expert('EXPERT');

  final String? value;

  const FarmingExperienceEnum(this.value);
}

enum FileTypeEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('pdf')
  pdf('pdf'),
  @JsonValue('xlsx')
  xlsx('xlsx'),
  @JsonValue('docx')
  docx('docx'),
  @JsonValue('zip')
  zip('zip'),
  @JsonValue('other')
  other('other');

  final String? value;

  const FileTypeEnum(this.value);
}

enum KycDocumentTypeEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('AADHAAR')
  aadhaar('AADHAAR'),
  @JsonValue('PAN')
  pan('PAN');

  final String? value;

  const KycDocumentTypeEnum(this.value);
}

enum LevelEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('beginner')
  beginner('beginner'),
  @JsonValue('intermediate')
  intermediate('intermediate'),
  @JsonValue('advanced')
  advanced('advanced'),
  @JsonValue('all_levels')
  allLevels('all_levels');

  final String? value;

  const LevelEnum(this.value);
}

enum NotificationNotificationTypeEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('WELCOME')
  welcome('WELCOME'),
  @JsonValue('APPROVED')
  approved('APPROVED'),
  @JsonValue('REJECTED')
  rejected('REJECTED'),
  @JsonValue('PROCESSING')
  processing('PROCESSING'),
  @JsonValue('WARNING')
  warning('WARNING'),
  @JsonValue('NEW_ENROLLMENT')
  newEnrollment('NEW_ENROLLMENT');

  final String? value;

  const NotificationNotificationTypeEnum(this.value);
}

enum NullEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('null')
  $null('null');

  final String? value;

  const NullEnum(this.value);
}

enum OrderStatusEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('PENDING')
  pending('PENDING'),
  @JsonValue('SUCCESS')
  success('SUCCESS'),
  @JsonValue('FAILED')
  failed('FAILED'),
  @JsonValue('REFUNDED')
  refunded('REFUNDED');

  final String? value;

  const OrderStatusEnum(this.value);
}

enum PurposeEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('PASSWORD_RESET')
  passwordReset('PASSWORD_RESET');

  final String? value;

  const PurposeEnum(this.value);
}

enum RoleEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('STUDENT')
  student('STUDENT'),
  @JsonValue('INSTRUCTOR')
  instructor('INSTRUCTOR'),
  @JsonValue('ADMIN')
  admin('ADMIN');

  final String? value;

  const RoleEnum(this.value);
}

enum Status1bcEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('DRAFT')
  draft('DRAFT'),
  @JsonValue('REVIEW')
  review('REVIEW'),
  @JsonValue('APPROVED')
  approved('APPROVED'),
  @JsonValue('REJECTED')
  rejected('REJECTED');

  final String? value;

  const Status1bcEnum(this.value);
}

enum Status76eEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('DRAFT')
  draft('DRAFT'),
  @JsonValue('PROCESSING')
  processing('PROCESSING'),
  @JsonValue('APPROVED')
  approved('APPROVED'),
  @JsonValue('REJECTED')
  rejected('REJECTED');

  final String? value;

  const Status76eEnum(this.value);
}

enum StatusC09Enum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('PENDING')
  pending('PENDING'),
  @JsonValue('VERIFIED')
  verified('VERIFIED'),
  @JsonValue('SUSPENDED')
  suspended('SUSPENDED');

  final String? value;

  const StatusC09Enum(this.value);
}

enum StudentNotificationNotificationTypeEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('WELCOME')
  welcome('WELCOME'),
  @JsonValue('NEW_COURSE')
  newCourse('NEW_COURSE'),
  @JsonValue('NEW_EBOOK')
  newEbook('NEW_EBOOK');

  final String? value;

  const StudentNotificationNotificationTypeEnum(this.value);
}

enum VerificationStatusEnum {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('PENDING')
  pending('PENDING'),
  @JsonValue('VERIFIED')
  verified('VERIFIED'),
  @JsonValue('SUSPENDED')
  suspended('SUSPENDED');

  final String? value;

  const VerificationStatusEnum(this.value);
}
