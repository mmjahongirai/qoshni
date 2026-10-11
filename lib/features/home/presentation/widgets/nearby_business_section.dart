import 'package:flutter/material.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/widgets/home_section_title.dart';
import 'package:qoshni/features/home/presentation/widgets/nearby_business_card.dart';

class NearbyBusinessSection extends StatelessWidget {
  const NearbyBusinessSection({
    required this.title,
    required this.businesses,
    super.key,
  });

  final String title;
  final List<NearbyBusinessItem> businesses;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionTitle(title: title),
        const SizedBox(height: 14),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: businesses.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return NearbyBusinessCard(business: businesses[index]);
            },
          ),
        ),
      ],
    );
  }
}
