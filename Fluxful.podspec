Pod::Spec.new do |s|
  s.name             = 'Fluxful'
  s.version          = '1.0.0'
  s.summary          = 'Module oriented Flux pattern implemented in Swift.'
  s.homepage         = 'https://github.com/kzlekk/Fluxful'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Natan Zalkin' => 'natan.zalkin@me.com' }
  s.source           = { :git => 'https://kzlekk@github.com/kzlekk/Fluxful.git', :tag => "#{s.version}" }
  s.module_name      = 'Fluxful'
  s.swift_version    = '5.0'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.watchos.deployment_target = '3.0'
  s.tvos.deployment_target = '10.0'

  s.subspec 'Core' do |cs|
    cs.source_files = 'Fluxful/*.swift'
  end

  s.subspec 'Reactive' do |cs|
    cs.dependency 'Fluxful/Core'
    cs.source_files = 'ReactiveFluxful/*.swift'
  end

  s.default_subspec = 'Core'

end
