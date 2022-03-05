import 'package:ticketapp/UI/services/bugsnag_wrapper.dart';
import 'package:ticketapp/model/custom_event_info.dart';
import 'package:ticketapp/model/link_type/invitation.dart';
import 'package:ticketapp/model/perk.dart';
import 'package:ticketapp/model/pre_sale/pre_sale.dart';
import 'package:ticketapp/model/pre_sale/pre_sale_prize.dart';
import 'package:ticketapp/repositories/link_repository.dart';
import 'birthday_lists/birthday_event_data.dart';
import 'discount.dart';
import 'release_manager.dart';
import 'ticket_release.dart';
import 'package:ticketapp/model/release_manager.dart';
import 'package:ticketapp/model/ticket_release.dart';

enum EventOccurrence { Single, Recurring }

extension EventOccurrenceExtension on EventOccurrence {
  String toDBString() {
    return this.toString().split(".")[1].toLowerCase();
  }

  String toDisplayString() {
    return this.toString().split(".")[1];
  }
}

class Event {
  Event._internal();

  String? docID;
  String name = "";
  String summary = "";
  String description = "";
  String coverImageURL = "";
  String address = "";
  String? venue;
  String venueName = "";
  String? ticketLink;
  String? promoter;
  String? organizer;
  String? contactEmail;
  String? recurringEventId;
  String? pixelId;

  late DateTime date;
  DateTime? endTime;
  List<String> tags = <String>[];
  List<String> images = <String>[];
  bool isSignedUp = false;
  bool isPrivateEvent = false;
  bool allowsBirthdaySignUps = false;
  List<ReleaseManager> releaseManagers = [];
  int cutoffTimeOffset = 0;
  String invitationMessage = "";
  String? ticketCheckoutMessage;
  double feePercent = 10.0;
  EventOccurrence? occurrence;
  BirthdayEventData? birthdayEventData;
  PreSale? preSale;
  List<CustomEventInfo> customEventInfo = [];
  List<Perk> availablePerks = [];
// We use this as an indicator that event tickets are still loading asynchronously
  // This means we don't have to wait on
  bool ticketsStillLoading = false;

  bool get preSaleEnabled => preSale != null && preSale!.enabled;
  bool get preSaleAvailable =>
      preSaleEnabled &&
      preSale!.registrationStartDate.isBefore(DateTime.now()) &&
      preSale!.registrationEndDate.isAfter(DateTime.now());

  /// Returns a list of release managers only including managers that are valid for the current link type
  /// For example: Tickets for Loyalty Member invites should not be shown to regular page visitors.
  List<ReleaseManager> getLinkTypeValidReleaseManagers() {
    List<ReleaseManager> validManagers = [];
    releaseManagers.forEach((element) {
      if (element.availableFor == null) {
        validManagers.add(element);
      } else {
        if (LinkRepository.instance.linkType is Invitation) {
          if (LinkRepository.instance.linkType.event!.docID == this.docID) {
            if (element
                .isAvailableFor(LinkRepository.instance.linkType.dbString)) {
              validManagers.add(element);
            }
          }
        } else {
          if (element
              .isAvailableFor(LinkRepository.instance.linkType.dbString)) {
            validManagers.add(element);
          }
        }
      }
    });

    return validManagers;
  }

  List<TicketRelease> getTicketReleases() {
    List<TicketRelease> release = [];
    for (int i = 0; i < releaseManagers.length; i++) {
      TicketRelease? tr = releaseManagers[i].getActiveRelease();
      if (tr != null) {
        release.add(tr);
      }
    }
    return release;
  }

  // bool getFreeTicket() {
  //   List<int> price = [];
  //   for (int i = 0; i < releaseManagers.length; i++) {
  //     List<TicketRelease> releases = releaseManagers[i].releases;

  //     for (int index = 0; index < releases.length; index++) {
  //      release = releases[index].ticketsLeft();

  //   }
  //   }
  //   return release;
  // }

  ReleaseManager? getReleaseManager(TicketRelease release) {
    for (int i = 0; i < releaseManagers.length; i++) {
      if (releaseManagers[i].releases.contains(release)) {
        return releaseManagers[i];
      }
    }
    return null;
  }

  bool soldOut() {
    return !releaseManagers.any((element) => !element.isSoldOut());
  }

  TicketRelease? getRelease(String releaseId) {
    for (int i = 0; i < releaseManagers.length; i++) {
      try {
        TicketRelease tr = releaseManagers[i]
            .releases
            .firstWhere((element) => element.docId == releaseId);
        return tr;
      } catch (_) {}
    }
    return null;
  }

  List<TicketRelease> getReleasesWithSingleTicketRestriction() {
    List<TicketRelease> releases = [];
    releaseManagers.forEach((manager) {
      if (manager.singleTicketRestriction) {
        releases.addAll(manager.releases);
      }
    });
    return releases;
  }

  List<ReleaseManager> getManagersWithActiveReleases() {
    List<ReleaseManager> activeManagers = [];
    this.releaseManagers.forEach((element) {
      if (element.getActiveRelease() != null) {
        activeManagers.add(element);
      }
    });
    return activeManagers;
  }

  List<TicketRelease> getAllReleases() {
    List<TicketRelease> releases = [];
    releaseManagers.forEach((manager) {
      releases.addAll(manager.releases);
    });
    return releases;
  }

  List<TicketRelease> getActiveReleases() {
    List<TicketRelease> releases = [];
    releaseManagers.forEach((manager) {
      TicketRelease? tr = manager.getActiveRelease();
      if (tr != null) {
        releases.add(tr);
      }
    });
    return releases;
  }

  List<TicketRelease> getReleasesWithoutRestriction() {
    List<TicketRelease> releases = [];
    releaseManagers.forEach((manager) {
      if (!manager.singleTicketRestriction) {
        TicketRelease? tr = manager.getActiveRelease();
        if (tr != null) {
          releases.add(tr);
        }
      }
    });
    return releases;
  }

  TicketRelease? getReleaseForBooking() {
    for (int i = 0; i < releaseManagers.length; i++) {
      if (releaseManagers[i].isAvailableFor("booking")) {
        TicketRelease? tr = releaseManagers[i].releases[0];
        return tr;
      }
    }
    return null;
  }

  factory Event.fromMap(String docId, Map<String, dynamic> data) {
    try {
      Event event = Event._internal();

      if (data.containsKey("name")) {
        event.name = data["name"];
      }
      if (data.containsKey("description")) {
        event.description = data["description"];
      }
      if (data.containsKey("summary")) {
        event.summary = data["summary"];
      }
      if (data.containsKey("coverimage")) {
        event.coverImageURL = data["coverimage"];
      }
      if (data.containsKey("address")) {
        event.address = data["address"];
      }
      if (data.containsKey("venue")) {
        event.venue = data["venue"];
      }
      if (data.containsKey("venuename")) {
        event.venueName = data["venuename"];
      }
      if (data.containsKey("ticketlink")) {
        event.ticketLink = data["ticketlink"];
      }
      if (data.containsKey("promoter")) {
        event.promoter = data["promoter"];
      }
      if (data.containsKey("organizer_id")) {
        event.organizer = data["organizer_id"];
      }
      if (data.containsKey("issignedup")) {
        event.isSignedUp = data["issignedup"];
      }
      if (data.containsKey("private_event")) {
        event.isPrivateEvent = data["private_event"];
      }
      if (data.containsKey("allowsbirthdaysignups")) {
        event.allowsBirthdaySignUps = data["allowsbirthdaysignups"];
        if (event.allowsBirthdaySignUps) {
          event.birthdayEventData = BirthdayEventData();
          if (data.containsKey("birthday_data")) {
            event.birthdayEventData!.price =
                data["birthday_data"]["price"] ?? 0;
            event.birthdayEventData!.maxGuests =
                data["birthday_data"]["max_guests"] ?? 0;
            if (data["birthday_data"].containsKey("benefits")) {
              {
                event.birthdayEventData!.benefits
                    .addAll(data["birthday_data"]["benefits"].cast<String>());
              }
            }
          }
        }
      }
      if (data.containsKey("contactemail")) {
        event.contactEmail = data["contactemail"];
      }
      if (data.containsKey("recurring_event_id")) {
        event.recurringEventId = data["recurring_event_id"];
        event.occurrence = EventOccurrence.Recurring;
      } else {
        event.occurrence = EventOccurrence.Single;
      }
      if (data.containsKey("tags")) {
        data["tags"].forEach((s) {
          event.tags.add(s.toString());
        });
      }
      if (data.containsKey("invite_link_cutoff")) {
        event.cutoffTimeOffset = data["invite_link_cutoff"];
      }
      if (data.containsKey("invitation_message")) {
        event.invitationMessage = data["invitation_message"];
      }
      if (data.containsKey("ticket_checkout_message")) {
        event.ticketCheckoutMessage = data["ticket_checkout_message"];
      }
      if (data.containsKey("images")) {
        data["images"].forEach((s) {
          event.images.add(s.toString());
        });
      }
      event.date = DateTime.fromMillisecondsSinceEpoch(
          data["date"].millisecondsSinceEpoch);

      if (data.containsKey("enddate")) {
        event.endTime = DateTime.fromMillisecondsSinceEpoch(
            data["enddate"].millisecondsSinceEpoch);
      }
      if (data.containsKey("presale_data") && data["presale_data"] != null) {
        try {
          event.preSale = PreSale(
              enabled: data["presale_data"]["enabled"] ?? false,
              registrationStartDate: DateTime.fromMillisecondsSinceEpoch(
                  data["presale_data"]["registration_start_date"]
                      .millisecondsSinceEpoch),
              registrationEndDate: DateTime.fromMillisecondsSinceEpoch(
                  data["presale_data"]["registration_end_date"]
                      .millisecondsSinceEpoch));
          if (data["presale_data"].containsKey("prizes")) {
            data["presale_data"]["prizes"].forEach((prize) {
              if (prize["prize_type"] == PreSaleDiscountPrize.dbTypeName) {
                event.preSale!.discountPrizes.add(PreSaleDiscountPrize(
                    discountType: DiscountType.values.firstWhere((element) =>
                        element.toDBString() == prize["discount_type"]),
                    discountValue: prize["discount_value"],
                    rank: prize["rank"],
                    type: PreSaleType.values.firstWhere((element) =>
                        element.toDBString() == prize["raffle_type"])));
              } else if (prize["prize_type"] == PreSaleTicketPrize.dbTypeName) {
                event.preSale!.ticketPrizes.add(PreSaleTicketPrize(
                    quantity: prize["quantity"],
                    managerDocID: prize["manager"],
                    rank: prize["rank"],
                    type: PreSaleType.values.firstWhere((element) =>
                        element.toDBString() == prize["raffle_type"])));
              } else if (prize["prize_type"] == PreSaleCustomPrize.dbTypeName) {
                event.preSale!.customPrizes.add(PreSaleCustomPrize(
                    prize: prize["prize"],
                    description: prize["description"],
                    rank: prize["rank"],
                    type: PreSaleType.values.firstWhere((element) =>
                        element.toDBString() == prize["raffle_type"])));
              }
            });
          }
        } catch (e) {
          print(e);
          event.preSale = null;
        }
      }

      if (data.containsKey("custom_info")) {
        data["custom_info"].forEach((info) {
          try {
            CustomEventInfo eventInfo = CustomEventInfo.fromMap(info);
            event.customEventInfo.add(eventInfo);
          } catch (_) {}
        });
      }

      if (data.containsKey("available_perks")) {
        data["available_perks"].forEach((p) {
          event.availablePerks.add(Perk(p["short"], p["description"]));
        });
      }

      if (data.containsKey("pixel_id")) {
        event.pixelId = data["pixel_id"];
      }

      event.docID = docId;

      return event;
    } catch (e, s) {
      print(e);
      print(s);
      BugsnagNotifier.instance.notify("Error loading Event $data $e", s,
          severity: ErrorSeverity.error);
      throw Exception("Error loading Event");
    }
  }
}
