import 'clarifying_question.dart';
import 'solution_option.dart';

class ProblemAnalysis {
  const ProblemAnalysis({
    required this.problem,
    required this.category,
    required this.problemType,
    required this.urgency,
    required this.location,
    required this.locationRequired,
    required this.needs,
    required this.missingInformation,
    required this.questions,
    required this.solutionOptions,
  });

  final String problem;
  final String category;
  final String problemType;
  final String urgency;
  final String location;
  final bool locationRequired;
  final List<String> needs;
  final List<String> missingInformation;
  final List<ClarifyingQuestion> questions;
  final List<SolutionOption> solutionOptions;
}