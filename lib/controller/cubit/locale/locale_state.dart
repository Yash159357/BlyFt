import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

abstract class LocaleState extends Equatable {
  const LocaleState();
  
  @override
  List<Object> get props => [];
}

class LocaleInitial extends LocaleState {}

class LocaleLoaded extends LocaleState {
  final Locale locale;
  
  const LocaleLoaded({required this.locale});
  
  @override
  List<Object> get props => [locale];
}
