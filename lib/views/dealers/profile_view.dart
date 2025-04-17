import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:provider/provider.dart';
import 'package:sari/models/views/dealer_view_model.dart';
import 'package:sari/providers/auth_provider.dart';
import 'package:sari/providers/product_provider.dart';
import 'package:sari/utils/constants.dart';
import 'package:sari/utils/errors.dart';
import 'package:sari/utils/mock_data.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/toast.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/views/dealers/sections/bookmark_section.dart';
import 'package:sari/views/layout_view.dart';
import 'package:sari/widgets/custom_alert_dialog.dart';
import 'package:sari/widgets/placeholder/icon_placeholder.dart';
import 'package:sari/widgets/preview_card.dart';
import 'package:sari/widgets/transactions/transaction_tabs.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileView extends StatefulWidget {
  static const String route = '/profile/:id';
  final String id;
  final bool isOwner;
  int step = 0;

  ProfileView({super.key, required this.id, required this.isOwner});

  @override
  ProfileViewState createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
  DealerViewModel _profile = MockData.dealerView;
  final _formKey = GlobalKey<FormState>();

  // Form Fields
  final _contactNumberController = TextEditingController();
  final _chatUrlController = TextEditingController();

  // Form Field State
  final _contactNumberKey = GlobalKey<FormFieldState>();
  final _chatUrlKey = GlobalKey<FormFieldState>();

  // Loading State
  late bool _loading;

  @override
  void initState() {
    _loading = true;
    _chatUrlController.text = "https://m.me/";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });

    WidgetsBinding.instance.ensureVisualUpdate();
    super.initState();
  }

  /// Fetch the data from the server.
  void _fetchData() async {
    // Get the dealer information.
    DealerViewModel? dealer =
        await context.read<DealerAuthProvider>().getUser(widget.id);
    setState(() {
      _profile = dealer ?? MockData.dealerView;
      _loading = false;
    });
  }

  /// Render an icon with a label.
  Widget _renderIconLabel(IconData icon, Color iconColor, String label) {
    return Row(children: [
      Icon(icon, size: 14, color: iconColor),
      Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Color(SariTheme.neutralPalette.get(50)))))
    ]);
  }

  /// Display a modal to edit the user's information.
  void _displayEditProfileModal() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: "Edit Profile",
            titleColor: SariTheme.primary,
            icon: FontAwesomeIcons.userPen,
            iconColor: SariTheme.tertiary,
            body: Form(
                key: _formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  /// [Contact Number]
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
                      child: TextFormField(
                          key: _contactNumberKey,
                          controller: _contactNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: OutlinedFieldBorder("Contact Number",
                              hintText: "e.g. 09123456789"),
                          autofocus: true,
                          onChanged: (_) {
                            _contactNumberKey.currentState?.validate();
                          },
                          validator: (value) {
                            // Disregard if the field is empty.
                            if (value == null || value.isEmpty) {
                              return null;
                            }

                            // Validate the phone number.
                            final phPhone = PhoneNumber.parse(value,
                                callerCountry: IsoCode.PH);
                            if (!phPhone.isValid(
                                type: PhoneNumberType.mobile)) {
                              return DealerError.INVALID_PHONE_ERROR;
                            }

                            return null;
                          })),

                  /// [Messenger Link]
                  TextFormField(
                      key: _chatUrlKey,
                      controller: _chatUrlController,
                      decoration: OutlinedFieldBorder("Messenger Link",
                          hintText: "https://m.me/username"),
                      autofocus: true,
                      onChanged: (_) {
                        _chatUrlKey.currentState?.validate();
                      },
                      validator: (value) {
                        // Disregard if the field is empty.
                        if (value == null || value.isEmpty) {
                          return null;
                        }

                        // Validate the messenger link.
                        if (!MESSENGER_REGEXP.hasMatch(value)) {
                          return DealerError.INVALID_CHAT_URL_ERROR;
                        }

                        return null;
                      }),
                ])),
            activeButtonLabel: "Save",
            onPressed: () async {
              // The user should add one of the fields.
              if (_contactNumberController.text.isEmpty &&
                  _chatUrlController.text.isEmpty) {
                ToastAlert.error(
                    context, "One of the fields should not be blank.");
                return;
              }

              if (_formKey.currentState!.validate()) {
                // Edit the user's information.
                int status =
                    await context.read<DealerAuthProvider>().updateDealer(
                          _contactNumberController.text,
                          _chatUrlController.text,
                        );

                // Close the modal.
                if (!context.mounted) return;
                Navigator.of(context).pop();
                if (status == StatusCode.NO_CONTENT) {
                  context.push(ProfileView.route.replaceAll(":id", widget.id));
                  ToastAlert.success(context, "Your changes have been saved.");
                }
              }
            },
          );
        });
  }

  /// Render a loading widget for the profile.
  Widget _renderLoader() {
    return Skeletonizer(
        child: Column(children: [
      /// [Profile Icon]
      Center(
          child: Stack(children: [
        // Icon
        ClipRRect(
            borderRadius: BorderRadius.circular(150),
            child: Image.network(
              MockData.dealer.photo_url,
              width: 80,
              height: 80,
            )),
      ])),

      /// [Dealer Name]
      Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
          child: Text(
            MockData.dealer.display_name,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.w900),
          )),

      /// [Contact Information]
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        // Email Address
        _renderIconLabel(FontAwesomeIcons.solidEnvelope, SariTheme.primary,
            MockData.dealer.email),

        // Seller Rating
        _renderIconLabel(
          FontAwesomeIcons.solidStar,
          SariTheme.yellow,
          "blarce@up.edu.ph",
        ),
      ]),

      /// [Tabs]
      Padding(
          padding: const EdgeInsets.fromLTRB(0, 28, 0, 0),
          child: TransactionTabs(
              step: widget.step,
              names: const ["Products", "Bookmarks"],
              palette: SariTheme.primaryPalette,
              onTabPressed: (int index) {})),

      /// [Products]
      Padding(
          padding: const EdgeInsets.fromLTRB(0, 28, 0, 60),
          child: GridView.count(
              childAspectRatio: 0.6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              children:
                  List.generate(MockData.dealerView.products!.length, (index) {
                return Padding(
                    padding: EdgeInsets.fromLTRB((index % 2 != 0) ? 8 : 0, 0,
                        (index % 2 != 0) ? 0 : 8, 0),
                    child: PreviewCard(
                        onBookmarkTap: (bool isLiked) async {},
                        product: MockData.dealerView.products![index]));
              }))),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DealerAuthProvider, ProductProvider>(
        builder: (context, dealerProvider, productProvider, child) {
      if (context.loaderOverlay.visible) {
        context.loaderOverlay.hide();
      }

      // Dealer
      if (dealerProvider.error.active) {
        ToastAlert.error(context, dealerProvider.error.error);
        dealerProvider.error.clear();
      }

      // Product
      if (productProvider.error.active) {
        ToastAlert.error(context, productProvider.error.error);
        productProvider.error.clear();
      }

      return LayoutView(
        page: 3,
        implied: false,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
            child: SingleChildScrollView(
                child: _loading
                    ? _renderLoader()
                    : Column(children: [
                        /// [Profile Icon]
                        Center(
                            child: Stack(children: [
                          // Icon
                          ClipRRect(
                              borderRadius: BorderRadius.circular(150),
                              child: Image.network(
                                _profile.dealer.photo_url,
                                width: 80,
                                height: 80,
                              )),

                          // Edit Button
                          if (widget.isOwner)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: SariTheme.secondary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: SariTheme.black.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: FaIcon(
                                      FontAwesomeIcons.pencil,
                                      color: SariTheme.white,
                                      size: 10,
                                    ),
                                    onPressed: () {
                                      _displayEditProfileModal();
                                    },
                                  )),
                            ),
                        ])),

                        /// [Dealer Name]
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
                            child: Text(
                              _profile.dealer.display_name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(fontWeight: FontWeight.w900),
                            )),

                        /// [Contact Information]
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Email Address
                              _renderIconLabel(FontAwesomeIcons.solidEnvelope,
                                  SariTheme.primary, _profile.dealer.email),

                              // Phone Number
                              if (_profile.dealer.contact_number != null &&
                                  _profile.dealer.contact_number !=
                                      MockData.NULL)
                                _renderIconLabel(
                                    FontAwesomeIcons.phone,
                                    SariTheme.secondary,
                                    _profile.dealer.contact_number.toString()),

                              // Seller Rating
                              _renderIconLabel(
                                  FontAwesomeIcons.solidStar,
                                  SariTheme.yellow,
                                  _profile.dealer.rating!.toStringAsFixed(2)),
                            ]),

                        /// [Chat Platforms]
                        if (_profile.dealer.chat_url?.isNotEmpty ?? false)
                          Padding(
                              padding: const EdgeInsets.fromLTRB(0, 28, 0, 0),
                              child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                      onPressed: () {
                                        context
                                            .read<DealerAuthProvider>()
                                            .redirectUrl(_profile
                                                .dealer.chat_url
                                                .toString());
                                      },
                                      icon: FaIcon(
                                          FontAwesomeIcons.facebookMessenger,
                                          size: 16,
                                          color: SariTheme.primary),
                                      style: FillButtonStyle(
                                          background: Color(SariTheme
                                              .primaryPalette
                                              .get(96))),
                                      label: Text(
                                        "Chat with ${_profile.dealer.display_name.split(' ')[0]} on Messenger",
                                        style: ButtonTextStyle(
                                            color: SariTheme.secondary),
                                      )))),

                        /// [Tabs]
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 28, 0, 0),
                            child: TransactionTabs(
                                step: widget.step,
                                names: const ["Products", "Bookmarks"],
                                palette: SariTheme.primaryPalette,
                                onTabPressed: (int index) {
                                  setState(() {
                                    widget.step = index;
                                  });
                                })),

                        /// [Products]
                        if (widget.step == 0)
                          Padding(
                              padding: const EdgeInsets.fromLTRB(0, 28, 0, 60),
                              child: (_profile.products!.isNotEmpty
                                  ? GridView.count(
                                      childAspectRatio: 0.6,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      crossAxisCount: 2,
                                      children: List.generate(
                                          _profile.products?.length ??
                                              [].length, (index) {
                                        return Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                (index % 2 != 0) ? 8 : 0,
                                                0,
                                                (index % 2 != 0) ? 0 : 8,
                                                0),
                                            child: PreviewCard(
                                                onBookmarkTap:
                                                    (bool isLiked) async {},
                                                product:
                                                    _profile.products![index]));
                                      }))
                                  : const IconPlaceholder(
                                      iconPath: "assets/package_boxes.png",
                                      title: "No products yet...",
                                      message:
                                          "This user currently has no products available.",
                                      topMargin: 28))),

                        if (widget.step == 1)
                          Padding(
                              padding: const EdgeInsets.fromLTRB(0, 28, 0, 60),
                              child: BookmarkSection(dealer: widget.id)),
                      ]))),
      );
    });
  }
}
