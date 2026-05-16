// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_lokalise/otel_lokalise.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_lokalise-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('keys.create_bulk records project + keys processed + platforms',
      () async {
    await tracedLokalise<String>(
      operation: 'keys.create_bulk',
      invoke: () async => const LokaliseCallResult(
        value: 'ok',
        result: LokaliseResult(
          teamId: 't_1',
          projectId: 'proj_1',
          projectType: 'web_mobile',
          keysProcessed: 250,
          languagesCount: 12,
          platformsCsv: 'ios,android,web',
          statusCode: 201,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('lokalise keys.create_bulk')!);
    expect(a['lokalise.project.type'], 'web_mobile');
    expect(a['lokalise.keys.processed'], 250);
    expect(a['lokalise.languages.count'], 12);
    expect(a['lokalise.platforms'], 'ios,android,web');
  });

  test('translations.update with MT records provider + word count', () async {
    await tracedLokalise<String>(
      operation: 'translations.update',
      invoke: () async => const LokaliseCallResult(
        value: 'ok',
        result: LokaliseResult(
          languageIso: 'fr',
          translationsProcessed: 80,
          machineTranslationProvider: 'deepl',
          machineTranslationWords: 4200,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('lokalise translations.update')!);
    expect(a['lokalise.language.iso'], 'fr');
    expect(a['lokalise.mt.provider'], 'deepl');
    expect(a['lokalise.mt.words'], 4200);
  });

  test('tasks.create records status + assignees', () async {
    await tracedLokalise<String>(
      operation: 'tasks.create',
      invoke: () async => const LokaliseCallResult(
        value: 'ok',
        result: LokaliseResult(
          taskId: 'task_1',
          taskStatus: 'in_progress',
          taskAssigneeCount: 3,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('lokalise tasks.create')!);
    expect(a['lokalise.task.status'], 'in_progress');
    expect(a['lokalise.task.assignee_count'], 3);
  });

  test('suppression skips spans', () async {
    await runWithoutLokaliseInstrumentationAsync(() async {
      await tracedLokalise<String>(
        operation: 'projects.list',
        invoke: () async => const LokaliseCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('lokalise '), isEmpty);
  });
}
