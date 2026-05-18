// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_lokalise_suppression.dart';

const _tracerName = 'dartastic_otel_libs_lokalise';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class LokaliseResult {
  const LokaliseResult({
    this.teamId,
    this.projectId,
    this.projectType,
    this.entityKind,
    this.entityId,
    this.languageIso,
    this.languagesCount,
    this.keysCount,
    this.keysProcessed,
    this.translationsProcessed,
    this.machineTranslationProvider,
    this.machineTranslationWords,
    this.taskId,
    this.taskStatus,
    this.taskAssigneeCount,
    this.platformsCsv,
    this.statusCode,
  });

  /// Lokalise team (organization).
  final String? teamId;

  final String? projectId;

  /// `localization_files` / `web_mobile` / `paged_documents` /
  /// `software_localization`.
  final String? projectType;

  /// `project` / `key` / `translation` / `language` / `task` /
  /// `comment` / `contributor` / `screenshot` / `webhook` /
  /// `glossary_term` / `branch`.
  final String? entityKind;

  final String? entityId;

  /// ISO language code (e.g., `en`, `fr`, `de-AT`).
  final String? languageIso;

  /// For bulk language operations.
  final int? languagesCount;

  /// Total keys in the project.
  final int? keysCount;

  /// Keys touched by this request (bulk operations).
  final int? keysProcessed;

  /// Translations touched (bulk operations or single-key translate).
  final int? translationsProcessed;

  /// `google` / `deepl` / `microsoft` / `amazon` — MT engine used for
  /// auto-translate.
  final String? machineTranslationProvider;

  /// Word count run through MT (Lokalise bills MT separately from
  /// hosting/keys).
  final int? machineTranslationWords;

  final String? taskId;

  /// `created` / `queued` / `in_progress` / `completed`.
  final String? taskStatus;

  final int? taskAssigneeCount;

  /// Comma-separated platforms keys are tagged for (`ios,android,web,other`).
  final String? platformsCsv;

  final int? statusCode;
}

class LokaliseCallResult<T> {
  const LokaliseCallResult({required this.value, this.result});
  final T value;
  final LokaliseResult? result;
}

/// Wraps a Lokalise API call in a CLIENT span. [operation] is one of
/// `projects.list`, `projects.create`, `keys.create_bulk`,
/// `keys.update_bulk`, `keys.delete_bulk`, `translations.update`,
/// `translations.list`, `tasks.create`, `tasks.update`,
/// `languages.add`, `screenshots.create`, `webhooks.create`,
/// `branches.create`, `branches.merge`, `glossary_terms.create`,
/// `files.upload`, `files.download`.
Future<T> tracedLokalise<T>({
  required String operation,
  required Future<LokaliseCallResult<T>> Function() invoke,
}) async {
  if (lokaliseInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'lokalise',
    'rpc.method': operation,
    'lokalise.operation': operation,
  };

  final span = _tracer().startSpan(
    'lokalise $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.teamId != null) {
        extras.add(OTel.attributeString(
          'lokalise.team.id',
          r.result!.teamId!,
        ));
      }
      if (r.result!.projectId != null) {
        extras.add(OTel.attributeString(
          'lokalise.project.id',
          r.result!.projectId!,
        ));
      }
      if (r.result!.projectType != null) {
        extras.add(OTel.attributeString(
          'lokalise.project.type',
          r.result!.projectType!,
        ));
      }
      if (r.result!.entityKind != null) {
        extras.add(OTel.attributeString(
          'lokalise.entity.kind',
          r.result!.entityKind!,
        ));
      }
      if (r.result!.entityId != null) {
        extras.add(OTel.attributeString(
          'lokalise.entity.id',
          r.result!.entityId!,
        ));
      }
      if (r.result!.languageIso != null) {
        extras.add(OTel.attributeString(
          'lokalise.language.iso',
          r.result!.languageIso!,
        ));
      }
      if (r.result!.languagesCount != null) {
        extras.add(OTel.attributeInt(
          'lokalise.languages.count',
          r.result!.languagesCount!,
        ));
      }
      if (r.result!.keysCount != null) {
        extras.add(OTel.attributeInt(
          'lokalise.keys.count',
          r.result!.keysCount!,
        ));
      }
      if (r.result!.keysProcessed != null) {
        extras.add(OTel.attributeInt(
          'lokalise.keys.processed',
          r.result!.keysProcessed!,
        ));
      }
      if (r.result!.translationsProcessed != null) {
        extras.add(OTel.attributeInt(
          'lokalise.translations.processed',
          r.result!.translationsProcessed!,
        ));
      }
      if (r.result!.machineTranslationProvider != null) {
        extras.add(OTel.attributeString(
          'lokalise.mt.provider',
          r.result!.machineTranslationProvider!,
        ));
      }
      if (r.result!.machineTranslationWords != null) {
        extras.add(OTel.attributeInt(
          'lokalise.mt.words',
          r.result!.machineTranslationWords!,
        ));
      }
      if (r.result!.taskId != null) {
        extras.add(OTel.attributeString(
          'lokalise.task.id',
          r.result!.taskId!,
        ));
      }
      if (r.result!.taskStatus != null) {
        extras.add(OTel.attributeString(
          'lokalise.task.status',
          r.result!.taskStatus!,
        ));
      }
      if (r.result!.taskAssigneeCount != null) {
        extras.add(OTel.attributeInt(
          'lokalise.task.assignee_count',
          r.result!.taskAssigneeCount!,
        ));
      }
      if (r.result!.platformsCsv != null) {
        extras.add(OTel.attributeString(
          'lokalise.platforms',
          r.result!.platformsCsv!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Lokalise HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
