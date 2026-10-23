/*import 'package:flutter/material.dart';

body: Padding(
  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        DateLabels.monthYear(currentMonth),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 6),

      Expanded(
        child: currentMonthReports.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) =>
              const Center(child: Text('Unable to fetch reports')),
          data: (currentReports) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${currentReports.length} report'
                  '${currentReports.length == 1 ? '' : 's'} received',
                  style: const TextStyle(color: Color(0xFF555555)),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: ListView.separated(
                    itemCount: currentReports.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      // Keep your existing itemBuilder here.
                      // Return the user/report ListTile or Card.
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ],
  ),
), */