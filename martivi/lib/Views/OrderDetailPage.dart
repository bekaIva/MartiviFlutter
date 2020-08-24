import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/Address.dart';
import 'package:martivi/Models/Order.dart';
import 'package:martivi/Models/Product.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/Models/enums.dart';
import 'package:martivi/Views/UserPage.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailPage extends StatefulWidget {
  final Order order;
  OrderDetailPage({this.order});

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.of(context).translate('Order')} ${AppLocalizations.of(context).translate('id')}: ${widget.order.orderId?.toString() ?? ''}',
          style: TextStyle(color: kIcons),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                      '${widget.order.products.length} ${AppLocalizations.of(context).translate('Product')} | ₾${widget.order.products.fold(0, (previousValue, element) => previousValue + element.price * element.quantity)}'),
                ],
              ),
              leading: Text('Ordered products'),
              children: widget.order.products
                  .map((e) => OrderedProductWidget(
                        productForm: e,
                      ))
                  .toList(),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance
                  .collection('/users')
                  .document(widget.order.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  User user = User.fromMap(snapshot.data.data);
                  return ExpansionTile(
                    title: Text(AppLocalizations.of(context).translate('User')),
                    subtitle: Text(user.displayName ??
                        user.email ??
                        (user.isAnonymous
                            ? AppLocalizations.of(context).translate('Guest')
                            : AppLocalizations.of(context)
                                .translate('Unknown'))),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserPage(
                                      user: user,
                                    ),
                                  ));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                (user?.photoUrl?.length ?? 0) > 0
                                    ? Container(
                                        width: 100,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                    user.photoUrl))),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: [
                                                    Colors.black54,
                                                    Colors.black54,
                                                    Colors.transparent
                                                  ],
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  stops: [0, .15, .5])),
                                          child: Container(
                                              padding: EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    user.displayName ??
                                                        (user.isAnonymous
                                                            ? AppLocalizations
                                                                    .of(context)
                                                                .translate(
                                                                    'Guest')
                                                            : ''),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: kIcons,
                                                        fontSize: 24),
                                                  ),
                                                  Text(
                                                    user.email ?? '',
                                                    style: TextStyle(
                                                        color: kIcons),
                                                  ),
                                                ],
                                              )),
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          Icon(
                                            FontAwesome.user,
                                            color: Colors.grey.shade600,
                                            size: 60,
                                          ),
                                          Text(user.displayName ??
                                              (user.isAnonymous
                                                  ? AppLocalizations.of(context)
                                                      .translate('Guest')
                                                  : '')),
                                        ],
                                      ),
                                Divider(
                                  height: 30,
                                ),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: Colors.grey.shade600,
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)
                                                      .translate('User info'),
                                                  style: TextStyle(
                                                      color:
                                                          Colors.grey.shade700),
                                                ),
                                                Divider(),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(AppLocalizations.of(
                                                            context)
                                                        .translate(
                                                            'User type')),
                                                    Text(AppLocalizations.of(
                                                            context)
                                                        .translate(
                                                            EnumToString.parse(
                                                                user.role)))
                                                  ],
                                                ),
                                                Divider(),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(AppLocalizations.of(
                                                            context)
                                                        .translate(
                                                            'User name')),
                                                    Text(user.displayName ??
                                                        (user.isAnonymous
                                                            ? AppLocalizations
                                                                    .of(context)
                                                                .translate(
                                                                    'Guest')
                                                            : '')),
                                                  ],
                                                ),
                                                Divider(),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(AppLocalizations.of(
                                                            context)
                                                        .translate('E-mail')),
                                                    SelectableText(
                                                        user.email ?? ''),
                                                  ],
                                                ),
                                                Divider(),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(AppLocalizations.of(
                                                            context)
                                                        .translate('Phone')),
                                                    SelectableText(
                                                      user.phoneNumber ?? '',
                                                      onTap: () async {
                                                        if (await canLaunch(
                                                            'tel:${user.phoneNumber}')) {
                                                          launch(
                                                              'tel:${user.phoneNumber}');
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                } else {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(kPrimary),
                      ),
                    );
                  } else
                    return SizedBox();
                }
              },
            ),
            ExpansionTile(
              title: Text(
                  AppLocalizations.of(context).translate('Delivery address')),
              subtitle: Text(widget.order.deliveryAddress.addressName),
              children: [
                Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(left: 4, top: 4, right: 4, bottom: 4),
                      child: Material(
                        borderRadius: BorderRadius.circular(4),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)
                                      .translate('Name')),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 24),
                                    child:
                                        Text(widget.order.deliveryAddress.name),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)
                                      .translate('Phone')),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 24),
                                    child: Text(widget
                                        .order.deliveryAddress.mobileNumber),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)
                                      .translate('Address')),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 24),
                                    child: Text(
                                        widget.order.deliveryAddress.address),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(3),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MapWidget(
                          address: widget.order.deliveryAddress,
                          onMapTap: (pos) {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) {
                                    return Material(
                                      type: MaterialType.transparency,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 5,
                                            right: 5,
                                            top: 110,
                                            bottom: 5),
                                        child: MapWidget(
                                          address: widget.order.deliveryAddress,
                                          onMapTap: (pos) {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ));
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            DeliveryStatusSteps(
              order: widget.order,
            )
          ],
        ),
      ),
    );
  }
}

class DeliveryStatusSteps extends StatefulWidget {
  final Order order;
  DeliveryStatusSteps({this.order});
  @override
  _DeliveryStatusStepsState createState() => _DeliveryStatusStepsState();
}

class _DeliveryStatusStepsState extends State<DeliveryStatusSteps> {
  List<Step> steps;
  @override
  void initState() {
    steps = DeliveryStatus.values.map((e) {
      return Step(
          isActive: widget.order.status == e ? true : false,
          state: StepState.indexed,
          content: Text(''),
          subtitle: Text(''),
          title: Text(EnumToString.parse(e)));
    }).toList();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      steps: steps,
    );
  }
}

class MapWidget extends StatelessWidget {
  final Function(LatLng) onMapTap;
  final UserAddress address;
  const MapWidget({this.address, this.onMapTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2.2,
      padding: EdgeInsets.only(left: 8, right: 8),
      child: Column(
        children: [
          Expanded(child: Builder(
            builder: (context) {
              Completer<GoogleMapController> _controller = Completer();
              return ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(4),
                child: GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onTap: onMapTap,
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                  },
                  initialCameraPosition: CameraPosition(
                      bearing: 180,
                      tilt: 0,
                      zoom: 18,
                      target: LatLng(address.coordinates.latitude,
                          address.coordinates.longitude)),
                  markers: address.coordinates != null
                      ? Set<Marker>.from([
                          Marker(
                            position: LatLng(address.coordinates.latitude,
                                address.coordinates.longitude),
                            markerId: MarkerId(AppLocalizations.of(context)
                                .translate('Delivery address')),
                            infoWindow: InfoWindow(
                              title: AppLocalizations.of(context)
                                  .translate('Delivery address'),
                            ),
                            visible: true,
                          )
                        ])
                      : null,
                  mapType: MapType.hybrid,
                ),
              );
            },
          )),
        ],
      ),
    );
  }
}

class OrderedProductWidget extends StatelessWidget {
  final ProductForm productForm;
  OrderedProductWidget({this.productForm});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 140,
          width: 160,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(
                fit: BoxFit.cover,
                image:
                    NetworkImage(productForm?.images?.first?.downloadUrl ?? ''),
              )),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                productForm.localizedFormName[
                    AppLocalizations.of(context).locale.languageCode],
                style: TextStyle(
                    fontFamily: "Sans",
                    color: Colors.black87,
                    fontWeight: FontWeight.w700),
              ),
              Text(
                productForm.localizedFormDescription[
                    AppLocalizations.of(context).locale.languageCode],
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.0,
                ),
              ),
              Text(
                '₾${productForm.price.toString()}',
                style: TextStyle(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
