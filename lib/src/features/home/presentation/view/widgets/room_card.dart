import 'package:flutter/material.dart';
import 'package:tuya_app/src/core/helpers/responsive_extensions.dart';
import 'package:tuya_app/src/features/home/domain/entities/room.dart';

class RoomCard extends StatelessWidget {
  final RoomEntity room;
  final bool isSelected;
  final VoidCallback onTap;

  const RoomCard({
    super.key,
    required this.room,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardSize = context.isMobile
        ? 80.0
        : context.isTablet
        ? 90.0
        : 100.0;
    final iconSize = context.isMobile
        ? 24.0
        : context.isTablet
        ? 28.0
        : 32.0;
    final fontSize = context.isMobile
        ? 12.0
        : context.isTablet
        ? 14.0
        : 16.0;
    final borderRadius = context.isMobile
        ? 12.0
        : context.isTablet
        ? 14.0
        : 16.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardSize,
        height: cardSize,
        margin: EdgeInsets.only(right: context.isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: context.isMobile ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: context.isMobile ? 4 : 6,
              offset: Offset(0, context.isMobile ? 2 : 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getRoomIcon(room.name),
              color: isSelected ? Colors.white : Colors.black,
              size: iconSize,
            ),
            SizedBox(height: context.isMobile ? 4 : 6),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.isMobile ? 4 : 6,
                vertical: context.isMobile ? 2 : 4,
              ),
              child: Text(
                room.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: fontSize * context.responsiveFontMultiplier,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: context.isMobile ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoomIcon(String roomName) {
    final name = roomName.toLowerCase();
    if (name.contains('living') || name.contains('lounge')) {
      return Icons.chair;
    } else if (name.contains('kitchen')) {
      return Icons.kitchen;
    } else if (name.contains('bedroom') || name.contains('bed')) {
      return Icons.bed;
    } else if (name.contains('bathroom') || name.contains('bath')) {
      return Icons.bathtub;
    } else if (name.contains('garage')) {
      return Icons.local_parking;
    } else if (name.contains('garden') || name.contains('yard')) {
      return Icons.yard;
    } else if (name.contains('office') || name.contains('study')) {
      return Icons.work;
    } else if (name.contains('dining')) {
      return Icons.dining;
    } else {
      return Icons.room;
    }
  }
}
