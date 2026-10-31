import 'package:flutter/material.dart';

import '../../core/widgets/app_card.dart';
import '../../data/models/organisation_content.dart';
import '../../data/models/shop_org.dart';

class OrganisationMemberCard extends StatelessWidget {
  const OrganisationMemberCard({super.key, required this.member});

  final OrganisationMember member;

  @override
  Widget build(BuildContext context) => AppCard(
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text(member.name),
          subtitle: member.role.isEmpty ? null : Text(member.role),
        ),
      );
}

class OrganisationMembersScreen extends StatelessWidget {
  const OrganisationMembersScreen({
    super.key,
    required this.organisation,
    required this.members,
  });

  final ShopOrg organisation;
  final Future<List<OrganisationMember>> members;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Members')),
        body: FutureBuilder<List<OrganisationMember>>(
          future: members,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                  child: Text('Could not load organisation members.'));
            }
            final memberList = snapshot.data ?? const [];
            if (memberList.isEmpty) {
              return const Center(child: Text('No members listed.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: memberList.length + 1,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Text(organisation.name,
                      style: Theme.of(context).textTheme.titleLarge);
                }
                final member = memberList[index - 1];
                return OrganisationMemberCard(member: member);
              },
            );
          },
        ),
      );
}
