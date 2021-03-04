// 0-17 are bars
// 20-22 are clubs
import 'package:ticketapp/services/bugsnag_wrapper.dart';

enum VenueType {
  Bar,
  SmallBar,
  LoungeBar,
  CocktailBar,
  SportsBar,
  CigarBar,
  DiveBar,
  HotelBar,
  NostalgiaBar,
  KaraokeBar,
  LiveMusicBar,
  BespokeBar,
  Pub,
  IrishPub,
  CollegeBar,
  ComedyClub,
  GentlemensBar,
  LadiesBar,
  GayBar,
  AdultEntertainment,
  Nightclub,
  DanceClub,
  SportsThemedNightclubs,
  LiveMusicVenue,
  Restaurant,
  RestaurantAndBar,
  FamilyRestaurant,
  RomanticRestaurant,
  ThemedRestaurant,
  Brewery,
  BeerGarden,
  BeerBar,
  SakeBar,
  WhiskeyBar,
  Winebar
}
enum VenueServices {
  CoatCheck,
  Dancing,
  HappyHourDrinks,
  HappyHourFood,
  SmokingArea,
  TableService,
  BottleService,
  LiveMusic,
  DJ
}
enum Drinks { NonAlcoholicBeverages, Beer, Wine, Spirits, Cocktails, Sake }
enum Food {
  BarSnacks,
  LiteMeals,
  BarMeals,
  Pizza,
  PubMeals,
  SeatedDining,
  Alacarte,
  Desserts,
  CheeseBoard,
  OutdoorSeating,
  TableService
}
enum TargetAudience {
  Singles,
  Couples,
  Groups,
  AdultOnly,
  InternationalTravelers,
  Locals,
  Tourist,
  YoungProfessionals,
  Professionals,
  LBGT,
  BoysNight,
  GirlsNight,
  MeetingNewPeople,
  PrivateEvents,
  BirthdayParties,
  HensNights,
  BucksNights,
  ChristmasParties,
  Weddings,
  EngagementParties,
  CorporateEvents
}
enum Atmosphere {
  Cosy,
  Casual,
  Formal,
  Upmarket,
  Festive,
  Lively,
  NoFrills,
  Quiet,
  Vintage,
  Energetic,
  Friendly,
  Social,
  Relaxed
}
enum Payment { Cash, Card, NFC, MobilePayments, Appollo }
enum VenueCategory { Regular, EventVenue, FestivalVenue }
enum HubSubscriprions { PriorityPass, QPass, CheckIn }

class Venue {
  Venue();

  String docID = "";
  String name;
  String address;
  String description;
  String coverImageURL;
  List<VenueType> venueType;
  int distance;
  num rating = 0;
  double lastCalculatedDistance = 9999;
  List<String> openinghours = List<String>();
  bool isSignedUp;
  List<String> events = List<String>();
  List<String> images = List<String>();
  List<VenueServices> services = List<VenueServices>();
  List<Drinks> drinks = List<Drinks>();
  List<Food> food = List<Food>();
  List<TargetAudience> targetAudience = List<TargetAudience>();
  List<Atmosphere> atmosphere = List<Atmosphere>();
  List<Payment> payment = List<Payment>();
  String dressCode = "";
  bool qPassAvailable = false;
  bool priorityPassAvailable = true;
  String priorityPassLimit = "-1";
  int qPassPrice = 3000;
  int price = 0;
  VenueCategory venueCategory = VenueCategory.Regular;
  Map<String, bool> hubSubscriptions = Map<String, bool>();

  factory Venue.fromMap(String docId, Map<String, dynamic> data) {
    Venue venue = Venue();

    bool isSignedUp = false;

    bool qpassAvailable = false;
    bool prioritypassAvailable = false;
    num rating;
    List<VenueType> venueType = List<VenueType>();

    List<VenueServices> services = List<VenueServices>();
    List<Drinks> drinks = List<Drinks>();
    List<Food> food = List<Food>();
    List<TargetAudience> targetAudience = List<TargetAudience>();
    List<Atmosphere> atmosphere = List<Atmosphere>();
    List<Payment> payment = List<Payment>();

    List<String> openinghours = List<String>(), events = List<String>(), images = List<String>();

    int price = 0;
    int qPassPrice = 3000;
    VenueCategory venueCategory = VenueCategory.Regular;
    Map<String, bool> hubSubscriptions = Map<String, bool>();

    try {
      venue.docID = docId;
      if (data.containsKey("name")) {
        venue.name = data["name"];
      }
      if (data.containsKey("description")) {
        venue.description = data["description"];
      }
      if (data.containsKey("address")) {
        venue.address = data["address"];
      }
      if (data.containsKey("coverimage")) {
        venue.coverImageURL = data["coverimage"];
      }
      if (data.containsKey("rating")) {
        rating = data["rating"];
      }
      if (data.containsKey("issignedup")) {
        isSignedUp = data["issignedup"];
      }
      if (data.containsKey("dresscode")) {
        venue.dressCode = data["dresscode"];
      }
      if (data.containsKey("venuetype")) {
        data["venuetype"].forEach((vt) {
          if (vt < VenueType.values.length) {
            venueType.add(VenueType.values[vt]);
          } else {
            print("Unknown Venue Type");
          }
        });
      }
      if (data.containsKey("events")) {
        data["events"].forEach((oh) {
          events.add(oh);
        });
      }
      if (data.containsKey("images")) {
        data["images"].forEach((oh) {
          images.add(oh);
        });
      }

      if (data.containsKey("venueatmosphere")) {
        data["venueatmosphere"].forEach((oh) {
          if (oh < Atmosphere.values.length) {
            atmosphere.add(Atmosphere.values[oh]);
          } else {
            print("Unknown Venue Atmosphere");
          }
        });
      }
      if (data.containsKey("venuedrinks")) {
        data["venuedrinks"].forEach((oh) {
          if (oh < Drinks.values.length) {
            drinks.add(Drinks.values[oh]);
          } else {
            print("Unknown Venue Drinks");
          }
        });
      }
      if (data.containsKey("venuefood")) {
        data["venuefood"].forEach((oh) {
          if (oh < Food.values.length) {
            food.add(Food.values[oh]);
          } else {
            print("Unknown Venue Food");
          }
        });
      }
      if (data.containsKey("venuepayment")) {
        data["venuepayment"].forEach((oh) {
          if (oh < Payment.values.length) {
            payment.add(Payment.values[oh]);
          } else {
            print("Unknown Venue Payment");
          }
        });
      }
      if (data.containsKey("venueservices")) {
        data["venueservices"].forEach((oh) {
          if (oh < VenueServices.values.length) {
            services.add(VenueServices.values[oh]);
          } else {
            print("Unknown Venue Service");
          }
        });
      }
      if (data.containsKey("venuetargetaudience")) {
        data["venuetargetaudience"].forEach((oh) {
          if (oh < TargetAudience.values.length) {
            targetAudience.add(TargetAudience.values[oh]);
          } else {
            print("Unknown Venue Target Audience");
          }
        });
      }
      if (data.containsKey("qpassavailable")) {
        qpassAvailable = data["qpassavailable"];
      }
      if (data.containsKey("prioritypassavailable")) {
        prioritypassAvailable = data["prioritypassavailable"];
      }
      if (data.containsKey("prioritypasslimit")) {
        venue.priorityPassLimit = data["prioritypasslimit"];
      }

      if (data.containsKey("price")) {
        price = data["price"];
      }
      if (data.containsKey("qpassprice")) {
        qPassPrice = data["qpassprice"];
      }
      if (data.containsKey("venuecategory")) {
        int cat = data["venuecategory"];
        if (cat < VenueCategory.values.length) {
          venueCategory = VenueCategory.values[cat];
        } else {
          print("Unknown Venue Category");
        }
      }
      if (data.containsKey("hubsubscriptions")) {
        data["hubsubscriptions"].forEach((k, v) {
          hubSubscriptions[k] = v;
        });
      }

      if (venueType.length == 0) {
        venueType.add(VenueType.Bar);
      }

      venue.venueType = venueType;
      venue.rating = rating;
      venue.venueType = venueType;
      venue.images = images;
      venue.events = events;
      venue.isSignedUp = isSignedUp;
      venue.openinghours = openinghours;
      venue.atmosphere = atmosphere;
      venue.targetAudience = targetAudience;
      venue.payment = payment;
      venue.food = food;
      venue.drinks = drinks;
      venue.services = services;
      venue.hubSubscriptions = hubSubscriptions;
      venue.qPassAvailable = qpassAvailable & hubSubscriptions.containsKey("qpass");
      venue.priorityPassAvailable = prioritypassAvailable & hubSubscriptions.containsKey("prioritypass");
      venue.price = price;
      venue.qPassPrice = qPassPrice;
      venue.venueCategory = venueCategory;

      return venue;
    } catch (e, s) {
      print("Error creating venue from data");
      print(e);
      print(data);
      BugsnagNotifier.instance.notify(e, s, severity: ErrorSeverity.error);
      return null;
    }
  }

  bool isSubscribedToHub(HubSubscriprions sub) {
    switch (sub) {
      case HubSubscriprions.PriorityPass:
        if (hubSubscriptions.containsKey("prioritypass") && hubSubscriptions["prioritypass"]) {
          return true;
        }
        break;
      case HubSubscriprions.QPass:
        if (hubSubscriptions.containsKey("qpass") && hubSubscriptions["qpass"]) {
          return true;
        }
        break;
      case HubSubscriprions.CheckIn:
        if (hubSubscriptions.containsKey("checkinbenefits") && hubSubscriptions["checkinbenefits"]) {
          return true;
        }
        break;
    }
    return false;
  }
}
