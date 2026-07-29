part of 'account_statement_cubit.dart';

@immutable
sealed class AccountStatementState {}

final class AccountStatementInitial extends AccountStatementState {}

final class SelectBranch extends AccountStatementState {}

final class GetAccountStatementLoading extends AccountStatementState {}

final class GetAccountStatementSuccess extends AccountStatementState {}

final class GetAccountStatementError extends AccountStatementState {}
