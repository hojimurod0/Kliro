import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/offer_model.dart';
import '../models/airport_hint_model.dart';

/// API response parsing uchun converter class
/// Turli API strukturalarni bitta formatga konvert qiladi
class ParsingConverter {
  /// Response data ni Map ga konvert qiladi
  static Map<String, dynamic> ensureMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const ParsingException('Server javobi noto\'g\'ri formatda');
  }

  /// Response data ni parse qiladi
  static T parseResponse<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (data == null) {
      throw const ParsingException('Server javobi bo\'sh');
    }
    if (data is! Map<String, dynamic>) {
      throw const ParsingException('Server javobi noto\'g\'ri formatda');
    }
    // Many endpoints wrap payload as { data: {...} } or { result: {...} }.
    // Normalize to the inner map when possible, keeping useful root metadata.
    Map<String, dynamic> root = data;
    Map<String, dynamic> payload = root;

    if (root['data'] is Map<String, dynamic>) {
      payload = Map<String, dynamic>.from(root['data'] as Map<String, dynamic>);
    } else if (root['result'] is Map<String, dynamic>) {
      payload =
          Map<String, dynamic>.from(root['result'] as Map<String, dynamic>);
    }

    // Sometimes payload itself is wrapped again as { data: {...} }
    if (payload['data'] is Map<String, dynamic>) {
      payload =
          Map<String, dynamic>.from(payload['data'] as Map<String, dynamic>);
    }

    // Preserve common timestamp field if present on root
    if (root['created_at'] != null && payload['created_at'] == null) {
      payload['created_at'] = root['created_at'];
    }

    return fromJson(payload);
  }

  /// Total sonini extract qiladi
  static int? extractTotal(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Turli strukturalardan total ni qidirish
      if (responseData.containsKey('total')) {
        final total = responseData['total'];
        if (total is int) {
          return total;
        } else if (total is num) {
          return total.toInt();
        }
      }
      if (responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is Map<String, dynamic> && data.containsKey('total')) {
          final total = data['total'];
          if (total is int) {
            return total;
          } else if (total is num) {
            return total.toInt();
          }
        }
      }
      if (responseData.containsKey('result')) {
        final result = responseData['result'];
        if (result is Map<String, dynamic>) {
          if (result.containsKey('total')) {
            final total = result['total'];
            if (total is int) {
              return total;
            } else if (total is num) {
              return total.toInt();
            }
          }
          if (result.containsKey('data')) {
            final resultData = result['data'];
            if (resultData is Map<String, dynamic> &&
                resultData.containsKey('total')) {
              final total = resultData['total'];
              if (total is int) {
                return total;
              } else if (total is num) {
                return total.toInt();
              }
            }
          }
        }
      }
    }
    return null;
  }

  /// Offers list ni turli strukturalardan extract qiladi
  static List<OfferModel> extractOffersList(dynamic responseData) {
    List<dynamic>? offersList;

    if (responseData is List<dynamic>) {
      offersList = responseData;
    } else {
      final dataMap = ensureMap(responseData);

      if (dataMap.containsKey('data')) {
        final dataValue = dataMap['data'];
        if (dataValue is List<dynamic>) {
          offersList = dataValue;
        }
      }
      if (offersList == null && dataMap.containsKey('offers')) {
        final offersValue = dataMap['offers'];
        if (offersValue is List<dynamic>) {
          offersList = offersValue;
        }
      }
      if (offersList == null && dataMap.containsKey('result')) {
        final result = dataMap['result'];
        if (result is Map<String, dynamic>) {
          if (result.containsKey('data')) {
            final resultData = result['data'];
            if (resultData is List<dynamic>) {
              offersList = resultData;
            }
          }
          if (offersList == null && result.containsKey('offers')) {
            final resultOffers = result['offers'];
            if (resultOffers is List<dynamic>) {
              offersList = resultOffers;
            }
          }
        }
      }
    }

    final offers = <OfferModel>[];
    if (offersList != null) {
      for (final item in offersList) {
        try {
          final apiData = item as Map<String, dynamic>;

          if (apiData.containsKey('directions') &&
              apiData['directions'] is List<dynamic>) {
            final directions = apiData['directions'] as List<dynamic>;

            if (directions.length > 1) {
              for (var i = 0; i < directions.length; i++) {
                final direction = directions[i] as Map<String, dynamic>;
                final singleDirectionData = Map<String, dynamic>.from(
                  apiData,
                );
                singleDirectionData['directions'] = [direction];
                final baseId =
                    apiData['id']?.toString() ?? apiData.hashCode.toString();
                singleDirectionData['id'] = '$baseId-$i';
                final offer = convertApiOfferToModel(singleDirectionData);
                offers.add(offer);
              }
            } else {
              final offer = convertApiOfferToModel(apiData);
              offers.add(offer);
            }
          } else {
            final offer = convertApiOfferToModel(apiData);
            offers.add(offer);
          }
        } catch (e, stackTrace) {
          AppLogger.error('Error parsing offer', e, stackTrace);
        }
      }
    }
    return offers;
  }

  /// Преобразует данные API в формат OfferModel
  static OfferModel convertApiOfferToModel(Map<String, dynamic> apiData) {
    // IMPORTANT:
    // OfferModel.id must be the BASE offer id (used for /fare-family).
    // fare_family.id is a specific tariff offer id and should be used only after user selects tariff.
    String? id = apiData['id']?.toString();
    id ??= apiData.hashCode.toString();

    String? price;
    String? currency;

    if (apiData.containsKey('fare_family')) {
      final fareFamily = apiData['fare_family'];
      if (fareFamily is Map<String, dynamic>) {
        if (fareFamily.containsKey('price')) {
          final priceValue = fareFamily['price'];
          if (priceValue is num) {
            price = priceValue.toString();
          } else if (priceValue is String) {
            price = priceValue;
          } else if (priceValue is Map<String, dynamic>) {
            price =
                priceValue['amount']?.toString() ??
                priceValue['value']?.toString();
            currency = priceValue['currency']?.toString();
          }
        }
        if (currency == null && fareFamily.containsKey('currency')) {
          currency = fareFamily['currency']?.toString();
        }
      }
    }

    if (price == null && apiData.containsKey('price')) {
      final priceValue = apiData['price'];
      if (priceValue is num) {
        price = priceValue.toString();
      } else if (priceValue is String) {
        price = priceValue;
      } else if (priceValue is Map<String, dynamic>) {
        price =
            priceValue['amount']?.toString() ?? priceValue['value']?.toString();
        currency = priceValue['currency']?.toString();
      }
    }

    if (currency == null && apiData.containsKey('currency')) {
      currency = apiData['currency']?.toString();
    }

    List<SegmentModel>? segments;
    if (apiData.containsKey('directions') &&
        apiData['directions'] is List<dynamic>) {
      final directions = apiData['directions'] as List<dynamic>;
      segments = <SegmentModel>[];
      for (final direction in directions) {
        if (direction is Map<String, dynamic>) {
          if (direction.containsKey('segments') &&
              direction['segments'] is List<dynamic>) {
            final directionSegments = direction['segments'] as List<dynamic>;
            for (final seg in directionSegments) {
              if (seg is Map<String, dynamic>) {
                final segment = convertApiSegmentToModel(seg);
                if (segment != null) {
                  segments.add(segment);
                }
              }
            }
          }
        }
      }
    } else if (apiData.containsKey('segments') &&
        apiData['segments'] is List<dynamic>) {
      final apiSegments = apiData['segments'] as List<dynamic>;
      segments = apiSegments
          .map((seg) {
            if (seg is Map<String, dynamic>) {
              return convertApiSegmentToModel(seg);
            }
            return null;
          })
          .whereType<SegmentModel>()
          .toList();
    }

    String? airline;
    if (segments != null && segments.isNotEmpty) {
      airline = segments.first.airline;
    } else if (apiData.containsKey('segments') &&
        apiData['segments'] is List<dynamic>) {
      final apiSegments = apiData['segments'] as List<dynamic>;
      if (apiSegments.isNotEmpty && apiSegments[0] is Map<String, dynamic>) {
        final firstSeg = apiSegments[0] as Map<String, dynamic>;
        if (firstSeg.containsKey('airline')) {
          final airlineData = firstSeg['airline'];
          if (airlineData is Map<String, dynamic>) {
            airline =
                airlineData['title']?.toString() ??
                airlineData['code']?.toString() ??
                airlineData['name']?.toString();
          } else if (airlineData is String) {
            airline = airlineData;
          }
        }
      }
    }

    String? duration;
    if (apiData.containsKey('directions') &&
        apiData['directions'] is List<dynamic>) {
      final directions = apiData['directions'] as List<dynamic>;
      int? totalMinutes;
      for (final direction in directions) {
        if (direction is Map<String, dynamic>) {
          if (direction.containsKey('route_duration')) {
            final routeDuration = direction['route_duration'];
            if (routeDuration is int) {
              totalMinutes = (totalMinutes ?? 0) + routeDuration;
            } else if (routeDuration is num) {
              totalMinutes = ((totalMinutes ?? 0) + routeDuration.toInt());
            }
          } else if (direction.containsKey('travel_time')) {
            final travelTime = direction['travel_time'];
            if (travelTime is int) {
              totalMinutes = (totalMinutes ?? 0) + travelTime;
            } else if (travelTime is num) {
              totalMinutes = ((totalMinutes ?? 0) + travelTime.toInt());
            }
          }
        }
      }
      if (totalMinutes != null) {
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;
        duration = '$hoursч $minutesм';
      }
    }

    return OfferModel(
      id: id,
      price: price,
      currency: currency,
      segments: segments,
      airline: airline,
      duration: duration,
    );
  }

  /// Преобразует сегмент из API в SegmentModel
  static SegmentModel? convertApiSegmentToModel(
    Map<String, dynamic> apiSegment,
  ) {
    try {
      String? departureAirport;
      String? arrivalAirport;
      String? departureAirportName;
      String? arrivalAirportName;
      String? departureTerminal;
      String? arrivalTerminal;
      String? aircraft;
      String? cabinClass;
      String? baggage;
      String? handBaggage;

      if (apiSegment.containsKey('departure') &&
          apiSegment['departure'] is Map<String, dynamic>) {
        final departure = apiSegment['departure'] as Map<String, dynamic>;
        if (departure.containsKey('airport')) {
          final airport = departure['airport'];
          if (airport is Map<String, dynamic>) {
            final code = airport['code']?.toString();
            departureAirportName =
                airport['title']?.toString() ??
                airport['name']?.toString() ??
                airport['fullname']?.toString();
            departureAirport = code ?? departureAirportName;
          }
        }
        departureTerminal =
            departure['terminal']?.toString() ??
            departure['terminal_name']?.toString() ??
            departure['terminalNumber']?.toString();
      }

      if (apiSegment.containsKey('arrival') &&
          apiSegment['arrival'] is Map<String, dynamic>) {
        final arrival = apiSegment['arrival'] as Map<String, dynamic>;
        if (arrival.containsKey('airport')) {
          final airport = arrival['airport'];
          if (airport is Map<String, dynamic>) {
            final code = airport['code']?.toString();
            arrivalAirportName =
                airport['title']?.toString() ??
                airport['name']?.toString() ??
                airport['fullname']?.toString();
            arrivalAirport = code ?? arrivalAirportName;
          }
        }
        arrivalTerminal =
            arrival['terminal']?.toString() ??
            arrival['terminal_name']?.toString() ??
            arrival['terminalNumber']?.toString();
      }

      String? departureTime;
      String? arrivalTime;

      if (apiSegment.containsKey('departure') &&
          apiSegment['departure'] is Map<String, dynamic>) {
        final departure = apiSegment['departure'] as Map<String, dynamic>;
        if (departure.containsKey('datetime')) {
          final datetime = departure['datetime'];
          if (datetime is String) {
            departureTime = datetime;
          }
        }
      }

      if (apiSegment.containsKey('arrival') &&
          apiSegment['arrival'] is Map<String, dynamic>) {
        final arrival = apiSegment['arrival'] as Map<String, dynamic>;
        if (arrival.containsKey('datetime')) {
          final datetime = arrival['datetime'];
          if (datetime is String) {
            arrivalTime = datetime;
          }
        }
      }

      String? flightNumber;
      if (apiSegment.containsKey('flight_number')) {
        flightNumber = apiSegment['flight_number']?.toString();
      }

      String? airline;
      if (apiSegment.containsKey('airline')) {
        final airlineData = apiSegment['airline'];
        if (airlineData is Map<String, dynamic>) {
          airline =
              airlineData['title']?.toString() ??
              airlineData['code']?.toString() ??
              airlineData['name']?.toString();
        } else if (airlineData is String) {
          airline = airlineData;
        }
      }

      // Aircraft / cabin / baggage (best-effort; API may differ)
      dynamic aircraftValue =
          apiSegment['aircraft'] ??
          apiSegment['aircraft_name'] ??
          apiSegment['aircraft_model'] ??
          apiSegment['equipment'] ??
          apiSegment['plane'];
      if (aircraftValue is Map<String, dynamic>) {
        aircraft =
            aircraftValue['title']?.toString() ??
            aircraftValue['name']?.toString() ??
            aircraftValue['model']?.toString() ??
            aircraftValue['code']?.toString();
      } else if (aircraftValue != null) {
        aircraft = aircraftValue.toString();
      }

      dynamic cabinValue =
          apiSegment['cabin_class'] ??
          apiSegment['cabin'] ??
          apiSegment['service_class'] ??
          apiSegment['class'];
      if (cabinValue is Map<String, dynamic>) {
        cabinClass =
            cabinValue['title']?.toString() ??
            cabinValue['name']?.toString() ??
            cabinValue['code']?.toString();
      } else if (cabinValue != null) {
        cabinClass = cabinValue.toString();
      }

      dynamic baggageValue =
          apiSegment['baggage'] ??
          apiSegment['baggage_allowance'] ??
          apiSegment['checked_baggage'];
      if (baggageValue is Map<String, dynamic>) {
        baggage =
            baggageValue['title']?.toString() ??
            baggageValue['value']?.toString() ??
            baggageValue['weight']?.toString();
      } else if (baggageValue != null) {
        baggage = baggageValue.toString();
      }

      dynamic handBaggageValue =
          apiSegment['hand_baggage'] ??
          apiSegment['handbags'] ??
          apiSegment['carry_on'] ??
          apiSegment['cabin_baggage'];
      if (handBaggageValue is Map<String, dynamic>) {
        handBaggage =
            handBaggageValue['title']?.toString() ??
            handBaggageValue['value']?.toString() ??
            handBaggageValue['weight']?.toString();
      } else if (handBaggageValue != null) {
        handBaggage = handBaggageValue.toString();
      }

      return SegmentModel(
        departureAirport: departureAirport,
        arrivalAirport: arrivalAirport,
        departureAirportName: departureAirportName,
        arrivalAirportName: arrivalAirportName,
        departureTerminal: departureTerminal,
        arrivalTerminal: arrivalTerminal,
        aircraft: aircraft,
        cabinClass: cabinClass,
        baggage: baggage,
        handBaggage: handBaggage,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        flightNumber: flightNumber,
        airline: airline,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error converting segment', e, stackTrace);
      return null;
    }
  }

  /// Airport hints list ni turli strukturalardan extract qiladi
  static List<AirportHintModel> extractAirportHintsList(dynamic responseData) {
    List<AirportHintModel> airports = [];

    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'] as Map<String, dynamic>?;
      if (data != null) {
        final airportsList = data['airports'] as List<dynamic>?;
        if (airportsList != null) {
          airports = airportsList
              .map((item) {
                try {
                  return AirportHintModel.fromJson(
                    item as Map<String, dynamic>,
                  );
                } catch (e) {
                  // Skip invalid airport items
                  return null;
                }
              })
              .whereType<AirportHintModel>()
              .toList();
        }

        final areasList = data['areas'] as List<dynamic>?;
        if (areasList != null) {
          final List<AirportHintModel> areaAirports = [];
          for (final area in areasList) {
            if (area is Map<String, dynamic>) {
              final areaAirportsList = area['airports'] as List<dynamic>?;
              if (areaAirportsList != null) {
                final parsedAreaAirports = areaAirportsList
                    .map((item) {
                      try {
                        return AirportHintModel.fromJson(
                          item as Map<String, dynamic>,
                        );
                      } catch (e) {
                        // Skip invalid airport items
                        return null;
                      }
                    })
                    .whereType<AirportHintModel>()
                    .toList();
                areaAirports.addAll(parsedAreaAirports);
              }
            }
          }
          airports.addAll(areaAirports);
        }
      }

      if (airports.isEmpty) {
        final dataList = responseData['data'] as List<dynamic>?;
        if (dataList != null) {
          airports = dataList
              .map((item) {
                try {
                  return AirportHintModel.fromJson(
                    item as Map<String, dynamic>,
                  );
                } catch (e) {
                  return null;
                }
              })
              .whereType<AirportHintModel>()
              .toList();
        }
      }

      if (airports.isEmpty) {
        final airportsList = responseData['airports'] as List<dynamic>?;
        if (airportsList != null) {
          airports = airportsList
              .map((item) {
                try {
                  return AirportHintModel.fromJson(
                    item as Map<String, dynamic>,
                  );
                } catch (e) {
                  return null;
                }
              })
              .whereType<AirportHintModel>()
              .toList();
        }
      }

      if (airports.isEmpty) {
        final resultList = responseData['result'] as List<dynamic>?;
        if (resultList != null) {
          airports = resultList
              .map((item) {
                try {
                  return AirportHintModel.fromJson(
                    item as Map<String, dynamic>,
                  );
                } catch (e) {
                  return null;
                }
              })
              .whereType<AirportHintModel>()
              .toList();
        }
      }
    } else if (responseData is List<dynamic>) {
      airports = responseData
          .map((item) {
            try {
              return AirportHintModel.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              return null;
            }
          })
          .whereType<AirportHintModel>()
          .toList();
    }
    return airports;
  }
}
