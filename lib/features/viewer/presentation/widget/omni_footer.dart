import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omni_preview/core/router/app_router.dart';
import 'package:omni_preview/features/common/widget/company_icon.dart';

class OmniFooter extends StatelessWidget {
  final VoidCallback? onNexinaPressed;
  final VoidCallback? onOmniPressed;
  const OmniFooter({super.key, this.onNexinaPressed, this.onOmniPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            context.pushNamed(AppRouter.setting);
          },
          child: CompanyIcon(),
        ),
      ),
    );
  }
}
