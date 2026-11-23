import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/context_extensions.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import 'models.dart';
import 'overview_modules.dart';

class MeasurementTab extends StatefulWidget {
  const MeasurementTab({super.key});

  @override
  State<MeasurementTab> createState() => _MeasurementTabState();
}

class _MeasurementTabState extends State<MeasurementTab> {
  final List<MeasurementItem> _measurements = [];

  Widget buildMeasurementTab() {
    final totalArea = _measurements.fold<double>(
      0,
      (sum, item) => sum + item.calculatedArea,
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 25.h),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildMeasurementHeader(totalArea),

              SizedBox(height: 8.h),

              ..._measurements.asMap().entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _buildMeasurementCard(entry.value, entry.key),
                );
              }),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementHeader(double totalArea) {
    return card(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.loc.totalCalculatedArea,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: const Color(0xFF777777),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${totalArea.toStringAsFixed(0)} m²',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              AppButton.small(
                text: context.loc.addLine,
                leadingIcon: Icons.add,
                onPressed: _showAddMeasurementBottomSheet,
                borderRadius: 5.r,
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
                textStyle: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementCard(MeasurementItem item, int index) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.loc.lineItem(index + 1, item.position),
                  style: TextStyle(
                    fontSize: 15.5.sp,
                    color: const Color(0xFF888888),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  _showEditMeasurementBottomSheet(item, index);
                },
                child: Icon(
                  Icons.edit_outlined,
                  size: 16.sp,
                  color: const Color(0xFF777777),
                ),
              ),

              SizedBox(width: 8.w),

              GestureDetector(
                onTap: () {
                  setState(() {
                    _measurements.removeAt(index);
                  });
                },
                child: Icon(
                  Icons.delete_outline,
                  size: 17.sp,
                  color: const Color(0xFFE00025),
                ),
              ),
            ],
          ),

          SizedBox(height: 5.h),

          Text(
            context.loc.frontScaffold,
            style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w700),
          ),

          SizedBox(height: 4.h),

          Text(
            'L: ${item.length.toStringAsFixed(2)} m × '
            'H: ${item.height.toStringAsFixed(2)} m × '
            'Qty: ${item.quantity}',
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF888888)),
          ),

          SizedBox(height: 7.h),

          Row(
            children: [
              Expanded(
                child: Text(
                  '"${item.remark}"',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF777777),
                  ),
                ),
              ),

              Text(
                '${item.calculatedArea.toStringAsFixed(0)} m²',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMeasurementBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return MeasurementBottomSheet(
          title: context.loc.addMeasurementItem,
          buttonText: context.loc.saveLineItem,
          onSave: (item) {
            setState(() {
              _measurements.add(item);
            });
          },
        );
      },
    );
  }

  void _showEditMeasurementBottomSheet(MeasurementItem item, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return MeasurementBottomSheet(
          title: context.loc.editMeasurementItem,
          buttonText: context.loc.saveChanges,
          initialItem: item,
          onSave: (updatedItem) {
            setState(() {
              _measurements[index] = updatedItem;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildMeasurementTab();
  }
}

class MeasurementBottomSheet extends StatefulWidget {
  const MeasurementBottomSheet({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onSave,
    this.initialItem,
  });

  final String title;
  final String buttonText;
  final MeasurementItem? initialItem;
  final ValueChanged<MeasurementItem> onSave;

  @override
  State<MeasurementBottomSheet> createState() => _MeasurementBottomSheetState();
}

class _MeasurementBottomSheetState extends State<MeasurementBottomSheet> {
  late final TextEditingController _positionController;
  late final TextEditingController _lengthController;
  late final TextEditingController _heightController;
  late final TextEditingController _remarkController;

  late int _quantity;
  late String _unit;

  @override
  void initState() {
    super.initState();

    final item = widget.initialItem;

    _positionController = TextEditingController(text: item?.position ?? '');

    _lengthController = TextEditingController(
      text: item?.length.toString() ?? '',
    );

    _heightController = TextEditingController(
      text: item?.height.toString() ?? '',
    );

    _remarkController = TextEditingController(text: item?.remark ?? '');

    _quantity = item?.quantity ?? 1;
    _unit = item?.unit ?? 'M²';
  }

  @override
  void dispose() {
    _positionController.dispose();
    _lengthController.dispose();
    _heightController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final length = double.tryParse(_lengthController.text) ?? 0;

    final height = double.tryParse(_heightController.text) ?? 0;

    final calculated = length * height * _quantity;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .90,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: 42.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 9.h),
              decoration: BoxDecoration(
                color: const Color(0xFFD5D5D5),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 8.h),
              child: Text(
                widget.title,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800),
              ),
            ),

            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 20.h),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _label(context.loc.position),

                        SizedBox(height: 6.h),

                        _textField(
                          controller: _positionController,
                          hint: 'e.g. North Facade (Front Wall)',
                        ),

                        SizedBox(height: 14.h),

                        Row(
                          children: [
                            Expanded(
                              child: _measurementField(
                                label: context.loc.length,
                                controller: _lengthController,
                                hint: '30.00 m',
                              ),
                            ),

                            SizedBox(width: 10.w),

                            Expanded(
                              child: _measurementField(
                                label: context.loc.height,
                                controller: _heightController,
                                hint: '30.00 m',
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 14.h),

                        Row(
                          children: [
                            Expanded(child: _quantityField()),

                            SizedBox(width: 10.w),

                            Expanded(child: _unitField()),
                          ],
                        ),

                        SizedBox(height: 8.h),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 8.h,
                          ),
                          color: const Color(0xFFF0F0F0),
                          child: Text(
                            context.loc.calculatedArea(
                              calculated.toStringAsFixed(2),
                              '${length.toStringAsFixed(0)}m × ${height.toStringAsFixed(0)}m × $_quantity',
                            ),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xFF888888),
                            ),
                          ),
                        ),

                        SizedBox(height: 14.h),

                        _label(context.loc.remark),

                        SizedBox(height: 6.h),

                        _textField(
                          controller: _remarkController,
                          hint: 'e.g. Standard steel frames required',
                        ),

                        SizedBox(height: 20.h),

                        AppButton(
                          text: widget.buttonText,
                          onPressed: _save,
                          borderRadius: 6.r,
                        ),

                        AppTextButton(
                          text: context.loc.cancel,
                          onPressed: () => Navigator.pop(context),
                          foregroundColor: const Color(0xFF555555),
                          textStyle: TextStyle(
                            fontSize: 17.sp,
                            color: const Color(0xFF555555),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF333333),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 16.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF999999)),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.r),
          borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.r),
          borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _measurementField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        SizedBox(height: 6.h),
        _textField(controller: controller, hint: hint),
      ],
    );
  }

  Widget _quantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(context.loc.quantity),
        SizedBox(height: 6.h),

        Container(
          height: 48.h,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD8D8D8)),
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_quantity > 1) {
                    setState(() {
                      _quantity--;
                    });
                  }
                },
                child: SizedBox(
                  width: 38.w,
                  child: Icon(
                    Icons.remove_circle_outline,
                    size: 18.sp,
                    color: const Color(0xFF777777),
                  ),
                ),
              ),

              Expanded(
                child: Center(
                  child: Text(
                    '$_quantity',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  setState(() {
                    _quantity++;
                  });
                },
                child: SizedBox(
                  width: 38.w,
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 18.sp,
                    color: const Color(0xFF777777),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _unitField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(context.loc.unit),
        SizedBox(height: 6.h),

        Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD8D8D8)),
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _unit,
              isExpanded: true,
              style: TextStyle(fontSize: 16.sp, color: const Color(0xFF444444)),
              items: const [
                DropdownMenuItem(value: 'M²', child: Text('M²')),
                DropdownMenuItem(value: 'M', child: Text('M')),
                DropdownMenuItem(value: 'PCS', child: Text('PCS')),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _unit = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  void _save() {
    final position = _positionController.text.trim();

    final length = double.tryParse(_lengthController.text.trim()) ?? 0;

    final height = double.tryParse(_heightController.text.trim()) ?? 0;

    if (position.isEmpty) {
      _showError(context.loc.pleaseEnterPosition);
      return;
    }

    if (length <= 0 || height <= 0) {
      _showError(context.loc.lengthHeightGreaterThanZero);
      return;
    }

    widget.onSave(
      MeasurementItem(
        position: position,
        length: length,
        height: height,
        quantity: _quantity,
        unit: _unit,
        remark: _remarkController.text.trim(),
      ),
    );

    Navigator.pop(context);
  }

  void _showError(String message) {
    AppSnackBar.showError(context, message);
  }
}
