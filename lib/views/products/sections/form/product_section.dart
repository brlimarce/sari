import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:sari/models/category_model.dart';
import 'package:sari/providers/context/product_form_provider.dart';
import 'package:sari/providers/product_provider.dart';
import 'package:sari/utils/constants.dart';
import 'package:sari/utils/errors.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/toast.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/views/products/product_form.dart';
import 'package:sari/widgets/form/form_button_group.dart';
import 'package:sari/widgets/form/form_section_header.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductSection extends StatefulWidget {
  String? category;
  final void Function() onNext;

  ProductSection({super.key, required this.onNext});

  @override
  ProductSectionState createState() => ProductSectionState();
}

class ProductSectionState extends State<ProductSection> {
  final _key = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormFieldState>();
  final _descriptionKey = GlobalKey<FormFieldState>();
  final _keywordKey = GlobalKey<FormFieldState>();

  // Field Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _keywordController = TextEditingController();

  // Field Values
  String _sellingValue = SELLING_TYPE.keys.first;
  String _thumbnail = "";

  List<Category> _categories = [];
  List<dynamic> _keywords = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCategories();
    });

    WidgetsBinding.instance.ensureVisualUpdate();

    // Initialize the form values.
    final provider = context.read<ProductFormProvider>();
    _nameController.text = provider.name;
    _descriptionController.text = provider.description;
    _sellingValue = provider.selling_type;
    _keywords = provider.product_keyword;
    _thumbnail = provider.thumbnail_url;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  /// Fetch the data from the server.
  void _fetchCategories() async {
    // Load the data from the server.
    List<Category> categories =
        await context.read<ProductProvider>().getAllCategories();
    if (!context.mounted) return;

    // Set the category value.
    setState(() {
      _categories = categories;

      // Initialize the category.
      if (context.read<ProductFormProvider>().category.isEmpty) {
        widget.category = categories.first.id;
      } else {
        widget.category = context.read<ProductFormProvider>().category;
      }
    });
  }

  /// Render a list of [Chip] to store the product keywords.
  ///
  /// It takes in a [List<String>] of keywords to be rendered as chips.
  List<Widget> _buildChips(List<dynamic> keywords) {
    return keywords.map((i) {
      return Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 8, 0),
          child: InputChip(
            backgroundColor: Color(SariTheme.primaryPalette.get(92)),
            deleteIconColor: Color(SariTheme.neutralPalette.get(70)),
            label: Text(i, style: TextStyle(color: SariTheme.primary)),
            shape: const RoundedRectangleBorder(
                side: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            onDeleted: () {
              // Remove the selected keyword.
              List<dynamic> temp = _keywords;
              temp.removeWhere((element) => element == i);
              setState(() => _keywords = temp);
            },
          ));
    }).toList();
  }

  /// Add a keyword to the product keywords list.
  ///
  /// It takes in a [String] value to be added to the keywords list.
  void _addKeyword(String value) {
    // Omit blank keywords.
    if (_keywordController.text.isEmpty) return;

    // Add the keyword to the list.
    List<dynamic> temp = _keywords;
    temp.add(value.toLowerCase());

    setState(() => _keywords = temp.toSet().toList());
    _keywordController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvokedWithResult: (_, result) {
          context.read<ProductFormProvider>().reset();
        },
        child: Form(
            key: _key,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 36),
                child: Column(children: [
                  /// [A: Basic Information]
                  FormSectionHeader(
                      title: "Start with a name...",
                      emojiPath: "assets/svg_icons/emoji_eyes.svg",
                      description:
                          "Let your buyers know what your product's all about."),

                  /// [Product Name]
                  TextFormField(
                      key: _nameKey,
                      controller: _nameController,
                      decoration: OutlinedFieldBorder("Product Name"),
                      autofocus: true,
                      onChanged: (_) {
                        _nameKey.currentState!.validate();
                      },
                      validator: (value) {
                        if (value!.length > 70) {
                          return ProductError.CHARACTER_LIMIT_ERROR(70);
                        }

                        if (value.isEmpty) {
                          return ProductError.REQUIRED_ERROR;
                        }

                        return null;
                      }),

                  /// [Product Description]
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: TextFormField(
                          key: _descriptionKey,
                          minLines: 4,
                          maxLines: 8,
                          textAlignVertical: TextAlignVertical.top,
                          controller: _descriptionController,
                          decoration: OutlinedFieldBorder(
                              "Describe your product.",
                              behavior: FloatingLabelBehavior.never,
                              alignLabelWithHint: true),
                          onChanged: (_) {
                            _descriptionKey.currentState!.validate();
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ProductError.REQUIRED_ERROR;
                            }

                            return null;
                          })),

                  /// [Product Category]
                  _categories.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: Skeletonizer(
                              child: DropdownButtonFormField(
                                  value: widget.category,
                                  onChanged: (value) {
                                    setState(() {
                                      widget.category = value!;
                                    });
                                  },
                                  decoration:
                                      OutlinedFieldBorder("Product Category"),
                                  items: [Category(id: "", name: "")].map((c) {
                                    return DropdownMenuItem(
                                        value: c.id, child: Text(c.name));
                                  }).toList())))
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: DropdownButtonFormField(
                            value: widget.category,
                            onChanged: (value) {
                              setState(() {
                                widget.category = value!;
                              });
                            },
                            decoration: OutlinedFieldBorder("Product Category"),
                            items: _categories.map((Category c) {
                              return DropdownMenuItem(
                                  value: c.id, child: Text(c.name));
                            }).toList(),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return ProductError.REQUIRED_ERROR;
                              }

                              return null;
                            },
                          )),

                  /// [Selling Type]
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: DropdownButtonFormField(
                        value: _sellingValue,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Selling Type',
                        ),
                        items: SELLING_TYPE.keys.map((String key) {
                          return DropdownMenuItem(
                              value: key, child: Text(SELLING_TYPE[key]!));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _sellingValue = value!;
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return ProductError.REQUIRED_ERROR;
                          }

                          return null;
                        },
                      )),

                  /// [Product Keywords]
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: TextFormField(
                        key: _keywordKey,
                        controller: _keywordController,
                        readOnly: _keywords.length >= 5,
                        decoration: OutlinedFieldBorder("Product Keywords",
                            hintText: _keywords.length >= 5
                                ? "You can only enter 5 keywords."
                                : "Enter up to 5 keywords only."),
                        onFieldSubmitted: (value) {
                          _addKeyword(value);
                          _keywordKey.currentState!.validate();
                        },
                        onChanged: (_) {
                          _keywordKey.currentState!.validate();
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r"[a-zA-Z0-9\-]"))
                        ],
                        validator: (value) {
                          if (value!.length > 20) {
                            return ProductError.CHARACTER_LIMIT_ERROR(20);
                          }

                          if (_keywords.isEmpty) {
                            return ProductError.REQUIRED_ERROR;
                          }

                          return null;
                        },
                      )),

                  // Keywords List
                  (_keywords.isNotEmpty)
                      ? SizedBox(
                          height: 56,
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: _buildChips(_keywords)))
                      : Container(),

                  /// [Upload Thumbnail]
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                      child: FormSectionHeader(
                        title: "Upload a thumbnail",
                        emojiPath: "assets/svg_icons/emoji_camera.svg",
                        description:
                            "Upload a 1:1 image of your product to give a good first impression.",
                      )),

                  // Image Preview
                  AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: SariTheme.primary,
                                width: 2,
                                strokeAlign: BorderSide.strokeAlignOutside),
                            borderRadius: BorderRadius.circular(8),
                          ),

                          // Render based on the image.
                          child: (_thumbnail.isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(_thumbnail),
                                      fit: BoxFit.cover))
                              : Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color:
                                        Color(SariTheme.neutralPalette.get(96)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Icon
                                        FaIcon(FontAwesomeIcons.images,
                                            size: 36,
                                            color: Color(SariTheme
                                                .neutralPalette
                                                .get(60))),

                                        // Text
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 16, 0, 0),
                                            child: Text(
                                                "Your thumbnail will show up here!\nTry to upload an image.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Color(SariTheme
                                                        .neutralPalette
                                                        .get(60)))))
                                      ])))),

                  // Select Image Button
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(0, 28, 0, 0),
                      child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              // Store the image as a URL.
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                      type: FileType.image,
                                      allowMultiple: false);

                              // Crop the image.
                              CroppedFile? image =
                                  await cropImage(result!.files.single.path!);
                              setState(() {
                                if (image != null) {
                                  _thumbnail = image.path;
                                }
                              });
                            } catch (e) {
                              if (!context.mounted) return;
                              ToastAlert.error(
                                  context, BaseError.UPLOAD_FAILED_ERROR);
                            }
                          },
                          icon: FaIcon(FontAwesomeIcons.cloudArrowUp,
                              size: 16, color: SariTheme.secondary),
                          style: FillButtonStyle(
                              background:
                                  Color(SariTheme.secondaryPalette.get(92))),
                          label: Text(
                            "${_thumbnail.isNotEmpty ? "CHANGE" : "UPLOAD"} IMAGE",
                            style: ButtonTextStyle(color: SariTheme.secondary),
                          ))),

                  /// [Button Group]
                  FormButtonGroup(
                      step: 0,
                      totalSteps: ProductFormView.steps,
                      onBack: () {},
                      onNext: () {
                        // Check if a thumbnail is uploaded.
                        if (_thumbnail.isEmpty) {
                          ToastAlert.error(
                              context, ProductError.EMPTY_IMAGE_ERROR);
                          _key.currentState!.validate();
                          return;
                        }

                        // Validate the rest of the form data.
                        if (_key.currentState!.validate()) {
                          context
                              .read<ProductFormProvider>()
                              .setProductDetails({
                            'category': widget.category,
                            'name': _nameController.text,
                            'description': _descriptionController.text,
                            'selling_type': _sellingValue,
                            'thumbnail_url': _thumbnail,
                            'product_keyword': _keywords
                          });

                          widget.onNext();
                        }
                      })
                ]))));
  }
}
